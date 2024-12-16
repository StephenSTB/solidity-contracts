// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721Enumerable, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import {Shop} from "../shop/Shop.sol";

// Contract to buy StevesTees
contract StevesTees is Shop, ERC721Enumerable{

    // Id of next NFT
    uint public TokenId = 0;

    // Constructor
    constructor(string[] memory _product_name, Product[] memory _products, address _usdc, bytes memory _signature)Shop(_product_name, _products, _usdc, _signature)ERC721Enumerable()ERC721("Steves' Tees", "ST"){
        
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
    function mintAll(address[] memory _buyers) public{
        for(uint i = 0; i < _buyers.length; i++){
            mint(_buyers[i]);
        }
    }
}