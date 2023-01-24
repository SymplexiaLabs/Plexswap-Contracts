// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ILiquidityVault {

    function autoLiquidity(uint256 _numTokensToLiquidity) external returns(uint256, uint256);

    function getTokenPrice() external view returns(uint256);

    function isInitialized() external view returns (bool);

    function isAddingLiquidity() external view returns (bool);

    function liquidityPair() external view returns (address);

    function baseToken() external view returns (address);
}