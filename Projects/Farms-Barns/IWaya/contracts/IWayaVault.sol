// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

interface IWayaVault {
    struct UserInfo {
        uint256 shares;
        uint256 lastDepositedTime;
        uint256 wayaAtLastUserAction;
        uint256 lastUserActionTime;
        uint256 lockStartTime;
        uint256 lockEndTime;
        uint256 userBoostedShare;
        bool locked;
        uint256 lockedAmount;
    }

    function userInfo(address _user) external view returns (UserInfo memory);
}