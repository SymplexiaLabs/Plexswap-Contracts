// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9;

interface IMintable {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}
