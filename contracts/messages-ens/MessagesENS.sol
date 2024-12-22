pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { Helper } from "../helper/Helper.sol";
 
contract MessagesENS is Ownable{

    // Messages
    mapping(address => mapping(address => Message[])) public MessagesChannel;

    mapping(address => address[]) public Messengers;

    // Keys used to encrypt user message information
    mapping(address => Key) public SignKeys;

    // List to allow a user to give messages.
    mapping(address => mapping(address => bool)) public AllowList;

    struct Message{
        address sender;
        uint256 value;
        string message;
        string image;
        bytes iv;
        bytes ephemPublicKey;
        bytes ciphertext;
        bytes mac;
    }

    // Struct to define keys of users.
    struct Key{
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    // Hash for SignKeys signature verification.
    bytes32 public EnableHash;

    modifier onlyRegistered(address _second){
        require(SignKeys[msg.sender].v != 0, "User not registered.");
        require(SignKeys[_second].v != 0, "Receiver is not registered.");
        _;
    }

    constructor(){
         EnableHash = ECDSA.toEthSignedMessageHash(bytes("Enable Messages."));
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

    // Blocks the receiver 
    function allow(address _sender, bool _allow) public onlyRegistered(_sender){
        AllowList[msg.sender][_sender] = _allow;
    }

    function message(address payable _receiver, string calldata _message, string calldata _image, bytes calldata _iv, bytes calldata _ephemPublicKey,  bytes calldata _ciphertext, bytes calldata _mac) public payable onlyRegistered(_receiver){
       require(AllowList[_receiver][msg.sender], "User has not allowed you to send messages.");
       require(AllowList[msg.sender][_receiver], "You have not allowed receiver to message you.");
       if(msg.value != 0){
            (bool sent, ) = _receiver.call{value: msg.value}("");
            require(sent, "Message with ether failed");
       }
       if(_receiver < msg.sender){
            MessagesChannel[_receiver][msg.sender].push(Message(msg.sender, msg.value, _message, _image, _iv, _ephemPublicKey, _ciphertext, _mac));
       }else{
            MessagesChannel[msg.sender][_receiver].push(Message(msg.sender, msg.value, _message, _image, _iv, _ephemPublicKey, _ciphertext, _mac));
       }
       Messengers[_receiver].push(msg.sender);
    }

    function retrieve(address _receiver, uint256 _start, uint256 _end) public view returns(Message[] memory _messages){
        require(_end > _start, "_start greater then or equal to _end");
        _messages = new Message[]((_end - _start + 1));
        if(_receiver < msg.sender){
            require(MessagesChannel[_receiver][msg.sender].length > _end, "Not enough messages.");
            for(uint256 i = 0; i < _messages.length; i++){
                _messages[i] = MessagesChannel[_receiver][msg.sender][_start + i];
            }
            return _messages;
        }
        require(MessagesChannel[msg.sender][_receiver].length > _end, "Not enough messages.");
        for(uint256 i = 0; i < _messages.length; i++){
            _messages[i] = MessagesChannel[msg.sender][_receiver][_start + i];
        }
        
    }

    function retrieve(address _receiver, uint256 _index) public view returns(Message memory _message){ 
        if(_receiver < msg.sender){
            require(MessagesChannel[_receiver][msg.sender].length >= _index, "Not enough messages.");
            return MessagesChannel[_receiver][msg.sender][_index];
        }
        require(MessagesChannel[msg.sender][_receiver].length >= _index, "Not enough messages.");
        return MessagesChannel[msg.sender][_receiver][_index];
    }

    function retrieve_messengers(uint256 _start, uint _end) public view returns(address[] memory _messengers){
        require(_end > _start, "_start greater then or equal to _end");
        require(Messengers[msg.sender].length > _end, "Not enough messengers");
        _messengers = new address[]((_end - _start + 1));
        for(uint256 i = 0; i < _messengers.length; i++){
            _messengers[i] = Messengers[msg.sender][_start + i];
        }
    }

    function retrieve_messenger(uint256 _index) public view returns(address _messenger){
        require(Messengers[msg.sender].length > _index, "Not enough messengers");
        return Messengers[msg.sender][_index];
    }

    function total(address _receiver) public view returns(uint256 _total){
        if(_receiver < msg.sender){
            return MessagesChannel[_receiver][msg.sender].length;
        }
        return MessagesChannel[msg.sender][_receiver].length;
    }

    function total_messengers() public view returns (uint256 _total){
        return Messengers[msg.sender].length;
    }

}