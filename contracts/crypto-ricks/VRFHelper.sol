// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;

import "vrf-solidity/contracts/VRF.sol";

/* helper functions */
contract VRFHelper{

    function verify(uint256[2] memory _publicKey, uint256[4] memory _proof, bytes memory _message) public pure returns (bool) {
        return VRF.verify(_publicKey, _proof, _message);
    }

    function decodeProof(bytes memory _proof) public pure returns(uint[4] memory _decodedProof){
        return VRF.decodeProof(_proof);
    }

    function decodePoint(bytes memory _point) public pure returns (uint[2] memory) {
        return VRF.decodePoint(_point);
    }

    function pointToAddress(uint _x, uint _y) public pure returns(address){
        return VRF.pointToAddress(_x, _y);
    }
}
    