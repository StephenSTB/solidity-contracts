pragma solidity ^0.8.0;
import  "@openzeppelin/contracts/access/Ownable.sol";
import "../public-keys/PublicKeys.sol";

contract Following is Ownable{
    // Following
    mapping(address => address[]) public FollowingChannel;
    mapping(address => mapping(address => bool)) public Following;
    mapping(address => uint) public Followers;

    PublicKeys public Public_Keys;

    constructor(address _public_keys) {
        Public_Keys = PublicKeys(_public_keys);
    }

    function follow(address _follow) public {
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(Public_Keys.onlyRegistered(_follow), "Follow not registered.");
        FollowingChannel[msg.sender].push(_follow);
        Following[msg.sender][_follow] = true;
        Followers[msg.sender] += 1;
    }

    function unfollow(address _unfollow) public {
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        
        for(uint i = 0; i < FollowingChannel[msg.sender].length; i++){
            if(FollowingChannel[msg.sender][i] == _unfollow){
                delete FollowingChannel[msg.sender][i];
                Following[msg.sender][_unfollow] = false;
                Followers[msg.sender] -= 1;
            }
        }
    }

    function following(uint _start, uint _end) public view returns(address[] memory _following){
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(_end <= FollowingChannel[msg.sender].length , "Invalid range 1.");
        require(_start < _end, "Invalid range 2.");
        require(_end - _start < 100, "Too many following requested.");
        _following = new address[](_end - _start);
        uint j = 0;
        for(uint i = _start; i < _end; i++){
            _following[j] = FollowingChannel[msg.sender][i];
        }
        return _following;
    }
}
