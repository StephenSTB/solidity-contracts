pragma solidity ^0.8.0;

import { PublicKeys } from "../public-keys/PublicKeys.sol";

contract Call is PublicKeys {

    mapping(address => mapping(address => EncryptedUUID)) public CallChannel;
    /*
    struct EncryptedMessage{
        bytes iv;
        bytes ephemPublicKey;
        bytes ciphertext;
        bytes mac;
    }*/
    
    struct EncryptedUUID{
        bytes encryptedSender;
        bytes encryptedUser;
    }

    modifier onlyRegistered(address _second){
        require(SignKeys[msg.sender].v != 0, "User not registered.");
        require(SignKeys[_second].v != 0, "Receiver is not registered.");
        _;
    }

    // set call channel
    function setCallChannel(address _second, EncryptedUUID memory _eUUID) public onlyRegistered(_second){
        CallChannel[msg.sender][_second] =  _eUUID;
    }
}