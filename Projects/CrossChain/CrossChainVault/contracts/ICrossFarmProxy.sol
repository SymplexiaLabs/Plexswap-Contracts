// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ICrossFarmProxy {
    function deposit(
        address _user,
        uint256 _pid,
        uint256 _amount,
        uint256 _nonce
    ) external;

    function withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount,
        uint256 _nonce
    ) external;

    function emergencyWithdraw(
        address _user,
        uint256 _pid,
        uint256 _nonce
    ) external;
}
