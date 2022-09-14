// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./MsgDataTypes.sol";
import "./MessageSenderApp.sol";
import "./MessageReceiverApp.sol";
import "./IMessageBus.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import "./IChiefFarmer.sol";
import "./CrossFarmingProxy.sol";

/** @title Celer crosschain application for users participate Plexswap CF farming in BSC chain from other EVM chains */
contract CrossFarming is MessageSenderApp, MessageReceiverApp {
    using SafeERC20 for IERC20;

    enum MessageTypes {
        Deposit,
        Withdraw,
        EmergencyWithdraw,
        Claim
    }
    // oracle data feeds
    enum Feeds {
        BNBUSD,
        ETHUSD
    }

    struct CrossFarmRequest {
        address account;
        uint256 pid;
        uint256 amount;
        MessageTypes msgType;
    }

    /// @notice waya token.
    address public immutable WAYA;
    /// @notice CF contract.
    IChiefFarmer public immutable CHIEFFARMER;

    // create CrossFarmingProxy contract estimate gas limit.
    uint256 public createProxyGasLimit;
    /// @notice Ratio of compensation for executor based on estimated gas fee.
    // 1: Different EVM chain, same source code may consume different gaslimit
    // 2: Different EVM chain have different gas price, gas fee = gaslimit * gasprice
    uint256 public compensationRate; // 100%-200%
    // Margin rate precision.
    uint256 public constant COMPENSATION_PRECISION = 1e5;
    // Max compensation rate
    uint256 public constant MAX_COMPENSATION_RATE = 2e5;

    // oracle BNB/USD & ETH/USD precision
    uint256 public constant PRICE_PRECISION = 1e8;
    // ETH/BNB exchange rate precison
    uint256 public constant EXCHANGE_RATE_PRECISION = 1e5;
    // oracle update time buffer
    uint256 public oracleUpdateBuffer;
    // oracle data feeds
    mapping(Feeds => AggregatorV3Interface) public oracles;
    // oracle latest roundId for different feed
    mapping(Feeds => uint256) public latestRoundId;
    // user account => proxy
    mapping(address => address) public uProxy;
    // proxy => user account
    mapping(address => address) public cProxy;
    // user nonce increment from 0
    mapping(address => uint64) nonces;
    // different message(operation) type have different estimate gas limit in BSC chain.
    ///@notice should be updated when EVM upgraded and gaslimit changed a lot.
    mapping(MessageTypes => uint256) public gaslimits;

    event NewOracle(address oracle);
    event FeeClaimed(uint256 amount);
    event CompensationRateUpdated(uint256 rate);
    event CreateProxyGasLimitUpdated(uint256 gaslimit);
    event ProxyCreated(address indexed proxy);
    event OracleBufferUpdated(uint256 oracleUpdateBuffer);
    event GasLimitUpdated(MessageTypes msgtype, uint256 gaslimit);
    event FarmingMessageReceived(
        address sender,
        uint64 srcChainId,
        uint64 nonce,
        MessageTypes msgType,
        address acount,
        uint256 pid,
        uint256 amount
    );

    constructor(
        address _messageBus,
        address _waya,
        IChiefFarmer _chieffarmer,
        address _oracle_bnb,
        address _oracle_eth,
        uint256 _oracleUpdateBuffer
    ) {
        messageBus = _messageBus;
        WAYA = _waya;
        CHIEFFARMER = _chieffarmer;
        oracles[Feeds.BNBUSD] = AggregatorV3Interface(_oracle_bnb);
        oracles[Feeds.ETHUSD] = AggregatorV3Interface(_oracle_eth);
        oracleUpdateBuffer = _oracleUpdateBuffer;
        // no compensation initially
        compensationRate = COMPENSATION_PRECISION;
    }

    // ============= called on source chain ============

    function sendFarmMessage(
        address _receiver, // destination contract address
        address _account, // cross-farm user account
        uint256 _pid, // mock pool id in Panwaya ChieffarmerV2.
        uint256 _amount, // the input token amount
        MessageTypes _msgType, // farm message type
        uint64 _dstChainId // destination chain id
    ) external payable {
        // encode a message, specifying how we want to distribute the funds on the destination chain
        bytes memory message = abi.encode(
            nonces[_account],
            CrossFarmRequest({account: _account, amount: _amount, pid: _pid, msgType: _msgType})
        );

        // ETH/USD price
        (uint80 ethRoundId, int256 ethPrice) = _getPriceFromOracle(Feeds.ETHUSD);
        latestRoundId[Feeds.BNBUSD] = ethRoundId;

        // BNB/USD price
        (uint80 bnbRoundId, int256 bnbPrice) = _getPriceFromOracle(Feeds.BNBUSD);
        latestRoundId[Feeds.BNBUSD] = bnbRoundId;

        // TODO Mock data(goerli network has no BNB/USD data feed, we used fixed number),should be removed in mainnet
        bnbPrice = 29735000000;

        require(bnbPrice > 0 && ethPrice > 0, "Abnormal prices");

        uint256 exchangeRate = (uint256(ethPrice) * EXCHANGE_RATE_PRECISION) / uint256(bnbPrice);

        uint256 fee = IMessageBus(messageBus).calcFee(message);
        // stack too deep, save one local variable(destTxFee)
        require(
            msg.value >=
                fee +
                    (tx.gasprice * estimateDestGaslimit(_account, _msgType) * exchangeRate * compensationRate) /
                    (EXCHANGE_RATE_PRECISION * COMPENSATION_PRECISION),
            "insufficient fee"
        );

        IMessageBus(messageBus).sendMessage{value: fee}(_receiver, _dstChainId, message);

        nonces[_account] += 1;
    }

    // ============== called on dest chain =============
    /**
     * @notice Only called by MessageBus
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address // executor who called the MessageBus execution function
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        // decode the message
        (uint64 n, CrossFarmRequest memory request) = abi.decode((_message), (uint64, CrossFarmRequest));

        // create proxy contract for 1st participate cross-farming user.
        CrossFarmingProxy proxy = CrossFarmingProxy(
            cProxy[request.account] == address(0) ? _createPrxoy(request.account) : cProxy[request.account]
        );

        if (request.msgType == MessageTypes.Deposit) {
            // Mint LP token for user
            IMintable(CHIEFFARMER.lpToken(request.pid)).mint(address(proxy), request.amount);
            proxy.deposit(request.account, request.pid, request.amount, n);
        } else if (request.msgType == MessageTypes.Withdraw) {
            proxy.withdraw(request.account, request.pid, request.amount, n);
        } else if (request.msgType == MessageTypes.EmergencyWithdraw) {
            proxy.emergencyWithdraw(request.account, request.pid, n);
        } else if (request.msgType == MessageTypes.Claim) {
            proxy.deposit(request.account, request.pid, 0, n);
        }

        emit FarmingMessageReceived(
            _sender,
            _srcChainId,
            n,
            request.msgType,
            request.account,
            request.pid,
            request.amount
        );

        return ExecutionStatus.Success;
    }

    /// @notice set oracle data feeds.
    function setOracles(Feeds _feed, address _oracle) external onlyOwner {
        require(_oracle != address(0), "Oracle feed can't be zero address");
        latestRoundId[_feed] = 0;
        oracles[_feed] = AggregatorV3Interface(_oracle);

        // Dummy check to make sure the interface implements this function properly
        oracles[_feed].latestRoundData();

        emit NewOracle(_oracle);
    }

    /// @notice set oracle update buffer, different oracle feeds have different update frequency,
    /// so the buffer should also be changed accordingly
    function setOracleUpdateBuffer(uint256 _oracleUpdateBuffer) external onlyOwner {
        oracleUpdateBuffer = _oracleUpdateBuffer;
        emit OracleBufferUpdated(oracleUpdateBuffer);
    }

    /// @notice set gas limit for different operation.
    function setGaslimits(MessageTypes _type, uint256 _gaslimit) external onlyOwner {
        require(_gaslimit > 0, "Gaslimit should be > zero");
        gaslimits[_type] = _gaslimit;
        emit GasLimitUpdated(_type, _gaslimit);
    }

    /// @notice gas price and gas limit will change, the compensation rate make executor will not run out of the gas.
    function setCompensationRate(uint256 _rate) external onlyOwner {
        require(_rate >= COMPENSATION_PRECISION && _rate <= MAX_COMPENSATION_RATE, "Invalid compenstation rate");
        compensationRate = _rate;
        emit CompensationRateUpdated(compensationRate);
    }

    /// @notice create farming-proxy contract gas limit cost.
    function setCreateProxyGasLimit(uint256 _gaslimit) external onlyOwner {
        createProxyGasLimit = _gaslimit;
        emit CreateProxyGasLimitUpdated(_gaslimit);
    }

    /// @notice estimate different operation consume gas limit in BSC chain.
    function estimateDestGaslimit(address _account, MessageTypes _msgType) public view returns (uint256 gaslimit) {
        gaslimit = gaslimits[_msgType];
        // 1st cross-chain tx should add create proxy gaslimit.
        if (nonces[_account] == 0) gaslimit += createProxyGasLimit;
    }

    ///@notice utility interface for FE to calc routing message fee charged by celer.
    function encodeMessage(
        address _account, // cross-farm user account
        uint256 _pid, // mock pool id in Panwaya ChieffarmerV2.
        uint256 _amount, // the input token amount
        MessageTypes _msgType // farm message type
    ) external view returns (bytes memory) {
        return
            abi.encode(
                nonces[_account],
                CrossFarmRequest({account: _account, amount: _amount, pid: _pid, msgType: _msgType})
            );
    }

    function drainToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    // send all gas token of this contract to owner
    function claimFee() external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
        emit FeeClaimed(amount);
    }

    /**
     * @notice When user 1st participate cross-farming, will create a new proxy contract for the user
     * which can stake LP token to ChieffarmerV2 pool on behalf of the user.
     * @param _user user account.
     * @return proxy proxy contract address.
     */
    function _createPrxoy(address _user) internal returns (address proxy) {
        require(cProxy[_user] == address(0), "User already has proxy");

        bytes memory bytecode = type(CrossFarmingProxy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, block.number, _user));

        assembly {
            proxy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // double check
        require(uProxy[proxy] == address(0), "Proxy already exists");

        cProxy[_user] = proxy;
        uProxy[proxy] = _user;
        // initialize
        CrossFarmingProxy(proxy).initialize(WAYA, CHIEFFARMER);

        emit ProxyCreated(proxy);
    }

    /**
     * @notice Get latest recorded price from oracle
     * If it falls below allowed buffer or has not updated, it would be invalid.
     */
    function _getPriceFromOracle(Feeds _feed) internal view returns (uint80, int256) {
        uint256 leastAllowedTimestamp = block.timestamp + oracleUpdateBuffer;
        (uint80 roundId, int256 price, , uint256 timestamp, ) = oracles[_feed].latestRoundData();
        require(timestamp <= leastAllowedTimestamp, "updated timestamp exceeded max timestamp buffer");
        require(uint256(roundId) > latestRoundId[_feed], "updated roundId must be larger than oracleLatestRoundId");
        return (roundId, price);
    }
}
