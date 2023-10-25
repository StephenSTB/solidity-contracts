// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20{

    constructor()ERC20("MockUSDC", "MUSDC"){
        _mint(msg.sender, 1000_000_000);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
    
}