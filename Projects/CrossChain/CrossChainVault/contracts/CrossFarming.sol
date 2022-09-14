// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.9;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./MsgDataTypes.sol";
import "./MessageSenderApp.sol";
import "./MessageReceiverApp.sol";
import "./ICrossFarmProxy.sol";

/** @title Celer crosschain application for users participate Plexswap CF farming in BSC chain from other EVM chains */
contract CrossFarming is MessageSenderApp, MessageReceiverApp {
    using SafeERC20 for IERC20;

    enum MessageSendType {
        Deposit,
        Withdraw,
        EmergencyWithdraw
    }

    struct FarmRequest {
        address account;
        uint256 pid;
        uint256 amount;
        MessageSendType msgType;
    }

    // Nonce increase from 1.
    uint64 nonce = 1;
    // The proxy contract which stake LP token to CF called by cross farming contract.
    ICrossFarmProxy public proxy;

    event MessageReceivedWithTransfer(
        address token,
        uint256 amount,
        address sender,
        uint64 srcChainId,
        address receiver,
        bytes message
    );

    event Refunded(address receiver, address token, uint256 amount, bytes message);

    event MessageReceived(address sender, uint64 srcChainId, uint64 nonce, bytes message);

    event FarmMessageReceived(
        address sender,
        uint64 srcChainId,
        uint64 nonce,
        MessageSendType msgType,
        address acount,
        uint256 pid,
        uint256 amount
    );

    constructor(address _messageBus) {
        messageBus = _messageBus;
    }

    function sendFarmMessage(
        address _receiver, // destination contract address
        address _account, // farm user address
        uint256 _pid, // the input token
        uint256 _amount, // the input token amount
        MessageSendType _msgType, // farm message type
        uint64 _dstChainId // destination chain id
    ) external payable {
        // encode a message, specifying how we want to distribute the funds on the destination chain
        bytes memory message = abi.encode(
            nonce,
            FarmRequest({account: _account, amount: _amount, pid: _pid, msgType: _msgType})
        );
        nonce++;
        sendMessage(_receiver, _dstChainId, message, msg.value);
    }

    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint32 _maxSlippage,
        bytes calldata _message,
        MsgDataTypes.BridgeSendType _bridgeSendType
    ) external payable {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        bytes memory message = abi.encode(msg.sender, _message);
        sendMessageWithTransfer(
            _receiver,
            _token,
            _amount,
            _dstChainId,
            nonce,
            _maxSlippage,
            message,
            _bridgeSendType,
            msg.value
        );
        nonce++;
    }

    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        // decode the message
        (uint64 n, FarmRequest memory request) = abi.decode((_message), (uint64, FarmRequest));

        if (request.msgType == MessageSendType.Deposit) {
            proxy.deposit(request.account, request.pid, request.amount, n);
        } else if (request.msgType == MessageSendType.Withdraw) {
            proxy.withdraw(request.account, request.pid, request.amount, n);
        } else if (request.msgType == MessageSendType.EmergencyWithdraw) {
            proxy.emergencyWithdraw(request.account, request.pid, n);
        }

        emit FarmMessageReceived(
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

    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        (address receiver, bytes memory message) = abi.decode((_message), (address, bytes));
        IERC20(_token).safeTransfer(receiver, _amount);
        emit MessageReceivedWithTransfer(_token, _amount, _sender, _srcChainId, receiver, message);
        return ExecutionStatus.Success;
    }

    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        (address receiver, bytes memory message) = abi.decode((_message), (address, bytes));
        IERC20(_token).safeTransfer(receiver, _amount);
        emit Refunded(receiver, _token, _amount, message);
        return ExecutionStatus.Success;
    }

    function drainToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function setProxy(address _proxy) external onlyOwner {
        require(_proxy != address(0), "setProxy: Invalid proxy address");
        proxy = ICrossFarmProxy(_proxy);
    }
}
