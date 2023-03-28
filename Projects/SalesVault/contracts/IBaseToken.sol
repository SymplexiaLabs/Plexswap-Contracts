// SPDX-License-Identifier: MIT


pragma solidity ^0.8.11;

import "./IERC20Metadata.sol";

interface IBaseToken is IERC20Metadata {

    function maxWalletBalance () external pure returns (uint256);

    function salesClearance () external;

    function SendAndFreeze (address _recipient, uint256 _amountToFreeze, uint64 _freezeDuration) external;

}
