// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./Ownable.sol";
import "./ERC20.sol";
import "./ERC20Burnable.sol";

/**
 * @title LP token for cross-farming Mastercher mock pool, It is mintable and burnable ERC20 token.
 * @notice After added token to ChieffarmerV2 pool, should transferOwnership to cross-farming contract in BSC chain.
 */
contract FarmToken is ERC20Burnable, Ownable {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}
