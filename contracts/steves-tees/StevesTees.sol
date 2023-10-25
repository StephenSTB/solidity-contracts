// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "../shop/Shop.sol";

// Contract to buy StevesTees
contract StevesTees is Shop, ERC721Enumerable{

    // Id of next NFT
    uint public TokenId = 0;

    // Constructor
    constructor(string[] memory _product_name, ProductInfo[] memory _product_info, address _usdc)Shop(_product_name, _product_info, _usdc)ERC721Enumerable("Steves' Tees", "ST"){
        
    }

    /*
    * Function to Mint a Steves Tee NFT.
    * @Param _buyer, buyer of the NFT.
    */
    function mint(address _buyer) public{
        _mint(_buyer, TokenId++);
    }

    /*
    * Funtion to Mint All Steves Tees NFT's for buyers.
    * @Param _buyers, buyers of NFT's
    */
    function mintAll(address[] _buyers) public{
        for(uint i = 0; i < _buyers.length; i++){
            mint(_buyers);
        }
    }
}