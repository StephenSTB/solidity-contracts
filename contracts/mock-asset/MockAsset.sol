// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockAsset is ERC20{

    uint8 public immutable decimal; 

    constructor(string memory _name, string memory _symbol, uint256 _amount, uint8 _decimal)ERC20(_name, _symbol){
        decimal = _decimal;
        _mint(msg.sender, _amount);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }
    
}