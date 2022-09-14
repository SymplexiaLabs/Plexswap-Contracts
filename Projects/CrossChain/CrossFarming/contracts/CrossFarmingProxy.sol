// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./IChiefFarmer.sol";
import "./IMintable.sol";

/** @title A proxy contract that stake LP tokens on behalf of all cross-chain users to CF called by cross farming contract */
contract CrossFarmingProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice WAYA token.
    address public WAYA;
    /// @notice CF contract.
    IChiefFarmer public CHIEFFARMER;

    address public factory;

    /// @notice unique tx nonce.
    uint64 public nonce;
    /// @notice (pid => (account => amount)).
    mapping(uint256 => mapping(address => uint256)) public userInfo;

    /// @notice whether user approved LP token to CF
    mapping(address => bool) public isApproved;

    event Deposit(address indexed caller, address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed caller, address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed caller, address indexed user, uint256 indexed pid);

    constructor() {
        factory = msg.sender;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "not factory");
        _;
    }

    modifier onlyNewNonce(address _sender, uint256 _nonce) {
        require(nonce < _nonce || nonce == 0, "Invalid nonce");
        _;
    }

    /**
     * @param _waya WAYA token address.
     * @param _chieffarmer ChieffarmerV2 address.
     */
    function initialize(address _waya, IChiefFarmer _chieffarmer) external {
        require(msg.sender == factory, "initialize: FORBIDDEN");
        WAYA = _waya;
        CHIEFFARMER = _chieffarmer;
    }

    /**
     * @notice Deposit LP tokens to pool.
     * @dev It can only be called by admin.
     * @param _user crosschain user address.
     * @param _pid The pool in in CF.
     * @param _amount staked LP token amount in other side chain.
     * @param _nonce cross-chain contract latest nonce.
     */
    function deposit(
        address _user,
        uint256 _pid,
        uint256 _amount,
        uint64 _nonce
    ) external nonReentrant onlyFactory onlyNewNonce(msg.sender, _nonce) {
        address lpToken = CHIEFFARMER.lpToken(_pid);
        if (!isApproved[lpToken]) {
            IERC20(lpToken).approve(address(CHIEFFARMER), type(uint256).max);
            isApproved[lpToken] = true;
        }

        uint256 before = IERC20(WAYA).balanceOf(address(this));
        CHIEFFARMER.deposit(_pid, _amount);
        // send WAYA reward to user
        harvest(_user, before);

        userInfo[_pid][_user] += _amount;
        nonce = _nonce;

        emit Deposit(msg.sender, _user, _pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from pool.
     * @param _user crosschain user address.
     * @param _pid The pool in in CF.
     * @param _amount staked LP token amount in other side chain.
     * @param _nonce cross-chain contract latest nonce.
     */
    function withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount,
        uint64 _nonce
    ) external nonReentrant onlyFactory onlyNewNonce(msg.sender, _nonce) {
        require(userInfo[_pid][_user] >= _amount, "withdraw: Insufficient token");

        uint256 before = IERC20(WAYA).balanceOf(address(this));
        // withdraw from CF pool
        CHIEFFARMER.withdraw(_pid, _amount);
        // burn LP token which equal to withdraw amount
        IMintable(CHIEFFARMER.lpToken(_pid)).burn(_amount);
        // send WAYA reward
        harvest(_user, before);

        userInfo[_pid][_user] -= _amount;
        nonce = _nonce;

        emit Withdraw(msg.sender, _user, _pid, _amount);
    }

    /**
     * @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
     * @dev It can only be called by admin.
     * @param _user crosschain user address.
     * @param _pid The pool in in CF.
     * @param _nonce cross-chain contract latest nonce.
     */
    function emergencyWithdraw(
        address _user,
        uint256 _pid,
        uint64 _nonce
    ) external nonReentrant onlyFactory onlyNewNonce(msg.sender, _nonce) {
        uint256 before = IERC20(WAYA).balanceOf(address(this));
        // withdraw all staked LP token from CF pool
        CHIEFFARMER.emergencyWithdraw(_pid);
        // burn LP token which euqal to user all staked amount
        IMintable(CHIEFFARMER.lpToken(_pid)).burn(userInfo[_pid][_user]);

        harvest(_user, before);

        userInfo[_pid][_user] = 0;
        nonce = _nonce;

        emit EmergencyWithdraw(msg.sender, _user, _pid);
    }

    function harvest(address _to, uint256 _before) internal {
        uint256 diff = IERC20(WAYA).balanceOf(address(this)) - _before;
        if (diff > 0) {
            IERC20(WAYA).safeTransfer(_to, diff);
        }
    }
}
