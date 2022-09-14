// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.9;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./Pausable.sol";
import "./CrossFarming.sol";

contract CrossChainVault is Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // user deposit original amount
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 mockPoolId; // Id of mock pool on BSC
        uint256 totalAmount;
    }

    address public CROSS_FARMING_ETH_CONTRACT;
    address public CROSS_FARMING_BSC_CONTRACT;

    uint8 public BSC_CHAIN_ID;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event UpdatePoolInfo(address indexed lpToken, uint256 mockPoolId);
    event Deposit(address indexed sender, uint256 pid, uint256 amount, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 pid, uint256 amount);
    event EmergencyWithdraw(address indexed sender, uint256 pid, uint256 amount);
    event UpdateCrossFarmingParams(
        address indexed sender,
        address ethCrossFarming,
        address bscCrossFarming,
        uint8 chainId
    );
    event Pause();
    event Unpause();

    receive() external payable {}

    /**
     * @notice Constructor
     * @param _ethCrossFarming: the Cross Farming contract on Ethereum
     * @param _bscCrossFarming: the Cross Farming contract on BSC
     * @param _chainId: the target chain id (on BSC)
     */
    constructor(
        address _ethCrossFarming,
        address _bscCrossFarming,
        uint8 _chainId
    ) {
        CROSS_FARMING_ETH_CONTRACT = _ethCrossFarming;
        CROSS_FARMING_BSC_CONTRACT = _bscCrossFarming;
        BSC_CHAIN_ID = _chainId;

        // staking pool
        poolInfo.push(PoolInfo({lpToken: IERC20(address(0)), mockPoolId: 0, totalAmount: 0}));
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(IERC20 _lpToken, uint256 _mockPoolId) public onlyOwner {
        require(_lpToken.balanceOf(address(this)) >= 0, "None BEP20 tokens");
        require(_mockPoolId != 0, "Mock pool id should not be 0");
        uint256 length = poolInfo.length;
        bool existed = false;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo memory pool = poolInfo[pid];
            if (pool.lpToken == _lpToken) {
                existed = true;
                break;
            }
        }
        require(existed == false, "LpToken existed");
        poolInfo.push(PoolInfo({lpToken: _lpToken, mockPoolId: _mockPoolId, totalAmount: 0}));

        emit UpdatePoolInfo(address(_lpToken), _mockPoolId);
    }

    /**
     * @notice Deposits funds into the Non Bsc Vault
     * @dev Only possible when contract not paused.
     * @param _pid: the pool id define in this contract
     * @param _amount: number of tokens to deposit (in LpToken)
     */
    function deposit(uint256 _pid, uint256 _amount) external payable whenNotPaused notContract {
        require(_pid != 0, "pid should be 0");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        // transfer token
        IERC20(pool.lpToken).safeTransferFrom(msg.sender, address(this), _amount);

        // send message
        (bool success, ) = CROSS_FARMING_ETH_CONTRACT.call{value: msg.value}(
            abi.encodeWithSignature(
                "sendFarmMessage(address,address,uint256,uint256,uint8,uint64)",
                CROSS_FARMING_BSC_CONTRACT,
                msg.sender,
                pool.mockPoolId,
                _amount,
                CrossFarming.MessageSendType.Deposit,
                BSC_CHAIN_ID
            )
        );

        require(success, "sendFarmMessage failed");

        // update poolInfo
        pool.totalAmount = pool.totalAmount + _amount;

        // update userInfo
        user.amount = user.amount + _amount;
        user.lastDepositedTime = block.timestamp;

        emit Deposit(msg.sender, _pid, _amount, block.timestamp);
    }

    /**
     * @notice Withdraws from funds from the Non Bsc Vault
     */
    function withdraw(uint256 _pid) external payable whenNotPaused notContract {
        require(_pid != 0, "pid should be 0");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 withdrawAmount = user.amount;

        // update poolInfo
        pool.totalAmount = pool.totalAmount - withdrawAmount;

        // update userInfo
        user.amount = 0;

        IERC20(pool.lpToken).safeTransfer(msg.sender, withdrawAmount);

        // send message
        (bool success, ) = CROSS_FARMING_ETH_CONTRACT.call{value: msg.value}(
            abi.encodeWithSignature(
                "sendFarmMessage(address,address,uint256,uint256,uint8,uint64)",
                CROSS_FARMING_BSC_CONTRACT,
                msg.sender,
                pool.mockPoolId,
                withdrawAmount,
                CrossFarming.MessageSendType.Withdraw,
                BSC_CHAIN_ID
            )
        );

        require(success, "sendFarmMessage failed");

        emit Withdraw(msg.sender, _pid, withdrawAmount);
    }

    /**
     * @notice EmergencyWithdraws from funds from the Non Bsc Vault
     */
    function emergencyWithdraw(uint256 _pid) external payable whenNotPaused notContract {
        require(_pid != 0, "pid should be 0");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 withdrawAmount = user.amount;

        // update poolInfo
        pool.totalAmount = pool.totalAmount - withdrawAmount;

        // update userInfo
        user.amount = 0;

        IERC20(pool.lpToken).safeTransfer(msg.sender, withdrawAmount);

        // send message
        (bool success, ) = CROSS_FARMING_ETH_CONTRACT.call{value: msg.value}(
            abi.encodeWithSignature(
                "sendFarmMessage(address,address,uint256,uint256,uint8,uint64)",
                CROSS_FARMING_BSC_CONTRACT,
                msg.sender,
                pool.mockPoolId,
                withdrawAmount,
                CrossFarming.MessageSendType.EmergencyWithdraw,
                BSC_CHAIN_ID
            )
        );

        require(success, "sendFarmMessage failed");

        emit EmergencyWithdraw(msg.sender, _pid, withdrawAmount);
    }

    /**
     * @notice Update pool info
     */
    function updatePoolInfo(uint256 _pid, uint256 _mockPoolId) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];

        // update poolInfo
        pool.mockPoolId = _mockPoolId;

        emit UpdatePoolInfo(address(pool.lpToken), _mockPoolId);
    }

    /**
     * @notice Update cross farming parameters
     */
    function updateCrossFarmingParams(
        address _ethCrossFarming,
        address _bscCrossFarming,
        uint8 _chainId
    ) external onlyOwner {
        require(address(_ethCrossFarming) != address(0), "no cross farming");
        require(address(_bscCrossFarming) != address(0), "no cross farming");
        CROSS_FARMING_ETH_CONTRACT = _ethCrossFarming;
        CROSS_FARMING_BSC_CONTRACT = _bscCrossFarming;
        BSC_CHAIN_ID = _chainId;

        emit UpdateCrossFarmingParams(msg.sender, _ethCrossFarming, _bscCrossFarming, _chainId);
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
