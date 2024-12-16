pragma solidity ^0.8.0;


contract UserAgeManager{
    uint256 public userAge;

    function setUserAge(uint256 _age) external{
        require(_age > 0 && _age < 150, "Age must be between 1 and 149");
        userAge = _age;
    }
}

interface IUserAgeManager{
    function setUserAge(uint256 _age) external;
}

contract AgeUpdater{
    function updateUserAgeV1(IUserAgeManager ageManager, uint256 _age) external{
        ageManager.setUserAge(_age);
    }

    function updateUserAgeV2(address ageManager, uint256 _age) external{
        (bool success, ) = ageManager.call(abi.encodeWithSignature("setUserAge(uint256)", _age));
    }

    function updateUserAgeV3(address ageManager, uint256 _age) external{
        bytes4 sig = bytes4(keccak256("setUserAge(uint256)"));
        assembly {
            let x := mload(0x04)
            mstore(x,sig)
            mstore(add(x,0x04), _age)
            let success := call(0, ageManager, 0, x, 0x24, x, 0)
        }
    }
}

