// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IVWaya {
    function deposit(
        address _user,
        uint256 _amount,
        uint256 _lockDuration
    ) external;

    function withdraw(address _user) external;
}