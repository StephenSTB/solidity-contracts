pragma solidity ^0.8.0;
import  "@openzeppelin/contracts/access/Ownable.sol";
import "../public-keys/PublicKeys.sol";

contract Following is Ownable{
    // Following
    mapping(address => address[]) public FollowingChannel;
    mapping(address => address[]) public FollowersChannel;

    mapping(address => mapping(address => bool)) public Follows;
    

    PublicKeys public Public_Keys;

    constructor(address _public_keys) {
        Public_Keys = PublicKeys(_public_keys);
    }

    function follow(address _follow) public {
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(Public_Keys.onlyRegistered(_follow), "Follow not registered.");
        FollowingChannel[msg.sender].push(_follow);
        FollowersChannel[_follow].push(msg.sender);
        Follows[msg.sender][_follow] = true;
    }

    function unfollow(address _unfollow) public {
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        require(Public_Keys.onlyRegistered(_unfollow), "Follow not registered.");
        
        for(uint i = 0; i < FollowingChannel[msg.sender].length; i++){
            if(FollowingChannel[msg.sender][i] == _unfollow){
                FollowingChannel[msg.sender][i] = FollowingChannel[msg.sender][FollowingChannel[msg.sender].length - 1];
                delete FollowingChannel[msg.sender][FollowingChannel[msg.sender].length - 1];
                Follows[msg.sender][_unfollow] = false;
            }
        }

        for(uint i = 0; i < FollowersChannel[_unfollow].length; i++){
            if(FollowersChannel[_unfollow][i] == msg.sender){
                FollowersChannel[_unfollow][i] = FollowersChannel[_unfollow][FollowersChannel[_unfollow].length - 1];
                delete FollowersChannel[_unfollow][FollowersChannel[_unfollow].length - 1];
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

    function followers(address _follow, uint _start, uint _end) public view returns(address[] memory _followers){
        require(Public_Keys.onlyRegistered(_follow), "User not registered.");
        require(_end <= FollowersChannel[_follow].length , "Invalid range 1.");
        require(_start < _end, "Invalid range 2.");
        require(_end - _start < 100, "Too many following requested.");
        _followers = new address[](_end - _start);
        uint j = 0;
        for(uint i = _start; i < _end; i++){
            _followers[j] = FollowersChannel[_follow][i];
        }
        return _followers;
    }

    function numFollowing() public view returns(uint){
        require(Public_Keys.onlyRegistered(msg.sender), "User not registered.");
        return FollowingChannel[msg.sender].length;
    }

    function numFollowers(address _follow) public view returns(uint){
        require(Public_Keys.onlyRegistered(_follow), "User not registered.");
        return FollowersChannel[_follow].length;
    }
}
