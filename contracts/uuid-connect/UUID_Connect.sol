// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

contract UUIDConnect{

    // Mapping to hold information of the product with the given name.
    mapping(address => string) public uuidmap;
    mapping(string => address) public addressmap;

    //constructor
    constructor(){
        
    }
    /*
    * Function to set the UUID of the address
    */
   function setUUID(string memory _uuid) public returns(string memory uuid, address sender){
        require(addressmap[_uuid] == address(0), "UUID has already been taken.");
        addressmap[_uuid] = msg.sender;
        uuidmap[msg.sender] = _uuid;
        return(_uuid, msg.sender); 
    }
}