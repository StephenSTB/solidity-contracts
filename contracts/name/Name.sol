// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../helper/Helper.sol";

contract Name {

    mapping(address => string) public Names;
    mapping(address =>  NameInfo) public Info;
    mapping(string => address) public NamesResolver;

    struct NameInfo{
        string name;
        string bio;
        string link;
        string avatar;
    }

    constructor(){

    }

    modifier  _validName(string memory _name, string memory _bio, string memory _link, string memory _avatar){
        require(keccak256(abi.encodePacked(NamesResolver[_name])) == keccak256(abi.encodePacked(address(0))), "The Name Already Exists.");
        require(bytes(_name).length > 2, "Name is to short");
        require(bytes(_name).length < 35, "Name is to long");
        require(bytes(_bio).length < 301, "Bio is to long.");
        require(Helper.isV1RawCID(_link), "Invalid Link Format.");
        require(Helper.isV1RawCID(_avatar), "Invalid Avatar Format.");
        _;
    }

    modifier _validEdit(string memory _bio, string memory _link, string memory _avatar){
            require(keccak256(abi.encodePacked(bytes(Names[msg.sender]))) != keccak256( abi.encodePacked(bytes("")) ), "Name Not Registerd.");
            require(bytes(_bio).length < 301, "Bio is to long.");
            require(Helper.isV1RawCID(_link), "Invalid Link Format.");
            require(Helper.isV1RawCID(_avatar), "Invalid Avatar Format.");
        _;
    }

    function createName(string memory _name, string memory _bio, string memory _link, string memory _avatar) public _validName(_name, _bio, _link, _avatar) {
        Names[msg.sender] = _name;
        Info[msg.sender] = NameInfo(_name, _bio, _link, _avatar);
        NamesResolver[_name] = msg.sender;
    }

    function editInfo(string memory _bio, string memory _link, string memory _avatar) public _validEdit(_bio, _link, _avatar){
        Info[msg.sender] = NameInfo(Names[msg.sender], _bio, _link, _avatar);
    }
}