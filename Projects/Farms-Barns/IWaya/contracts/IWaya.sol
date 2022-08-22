// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./SafeERC20.sol";
import "./IWayaVault.sol";

contract IWaya is Ownable {

    IWayaVault public immutable wayaVault;

    address public admin;
    // threshold of locked duration
    uint256 public ceiling;

    uint256 public constant MIN_CEILING_DURATION = 1 weeks;

    event UpdateCeiling(uint256 newCeiling);

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "None admin!");
        _;
    }

    /**
     * @notice Constructor
     * @param _wayaVault: Waya pool contract
     * @param _admin: admin of the this contract
     * @param _ceiling: the max locked duration which the linear decrease start
     */
    constructor(
        IWayaVault _wayaVault,
        address _admin,
        uint256 _ceiling
    ) {
        require(_ceiling >= MIN_CEILING_DURATION, "Invalid ceiling duration");
        wayaVault = _wayaVault;
        admin = _admin;
        ceiling = _ceiling;
    }

    /**
     * @notice calculate iWaya credit per user.
     * @param _user: user address.
     */
    function getUserCredit(address _user) external view returns (uint256) {
        require(_user != address(0), "getUserCredit: Invalid address");

        IWayaVault.UserInfo memory userInfo = wayaVault.userInfo(_user);

        if (!userInfo.locked || block.timestamp > userInfo.lockEndTime) {
            return 0;
        }

        // lockEndTime always >= lockStartTime
        uint256 lockDuration = userInfo.lockEndTime - userInfo.lockStartTime;

        if (lockDuration >= ceiling) {
            return userInfo.lockedAmount;
        } else if (lockDuration < ceiling && lockDuration >= 0) {
            return (userInfo.lockedAmount * lockDuration) / ceiling;
        }
    }

    /**
     * @notice update ceiling thereshold duration for iWaya calculation.
     * @param _newCeiling: new threshold duration.
     */
    function updateCeiling(uint256 _newCeiling) external onlyAdmin {
        require(_newCeiling >= MIN_CEILING_DURATION, "updateCeiling: Invalid ceiling");
        require(ceiling != _newCeiling, "updateCeiling: Ceiling not changed");
        ceiling = _newCeiling;
        emit UpdateCeiling(ceiling);
    }
}