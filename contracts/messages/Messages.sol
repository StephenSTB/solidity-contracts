pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../public-keys/PublicKeys.sol";
import "../following/Following.sol";
contract Messages is Ownable{
    // Messages
    mapping(address => mapping(address => Message[])) public MessagesChannel;

    struct Message{
        address to;
        uint256 value;
        string message;
        bytes message_encrypted;
    }

    PublicKeys public Public_Keys;
    Following public Follow;

    constructor(address _public_keys, address _follow) {
        Public_Keys = PublicKeys(_public_keys);
        Follow = Following(_follow);
    }

    function numMessages(address _from) public view returns(uint){
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(Public_Keys.onlyRegistered(_from), "From not registered.");
        return MessagesChannel[msg.sender][_from].length;
    }

    function sendMessage(Message memory _message) public payable {
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(Public_Keys.onlyRegistered(_message.to), "To not registered.");
        require(Follow.Following(msg.sender, _message.to), "User not following.");
        require(Follow.Following(_message.to, msg.sender), "To not following.");
        require(msg.value == _message.value, "Incorrect value.");
        MessagesChannel[_message.to][msg.sender].push(_message);
    }

}