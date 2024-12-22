pragma solidity ^ 0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract PublicKeys is Ownable{

    // Keys used to encrypt user message information
    mapping(address => Key) public SignKeys;

    // Struct to define keys of users.
    struct Key{
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    // Hash for SignKeys signature verification.
    bytes32 public EnableHash;

    constructor(){
        EnableHash = ECDSA.toEthSignedMessageHash(bytes("Enable Public Key."));
    }

    function register(bytes memory _signature) public{

        require(SignatureChecker.isValidSignatureNow(msg.sender, EnableHash, _signature), "Invalid Signature.");
        
        bytes32 _r;
        bytes32 _s;
        uint8 _v;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        /// @solidity memory-safe-assembly
        assembly {
            _r := mload(add(_signature, 0x20))
            _s := mload(add(_signature, 0x40))
            _v := byte(0, mload(add(_signature, 0x60)))
        }

        SignKeys[msg.sender] = Key(_r, _s, _v);
    }

}