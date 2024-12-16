// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "./VRFHelper.sol";

contract CryptoRicks is ERC721Enumerable{

    using Counters for Counters.Counter;

    using Strings for uint256;

    address public immutable Distributor;

    uint public immutable PublicKeyPointX;

    uint public immutable PublicKeyPointY;

    uint public MaxSupply;

    uint public MintValue;

    string public BaseURI;

    bytes32 public Root;

    bool ProofVariables = false;

    VRFHelper helper;

    Counters.Counter public TokenIds;

    modifier mintable(){
        require(TokenIds.current() + 1 < MaxSupply, "The maximum number of ricks have been minted.");
        require(ProofVariables, "The BaseURI, VRF Public Key and Merkle Root have not been set");
        require(msg.value >= MintValue, "Not enough Ether was sent.");
        _;
    }

    modifier onlyDistributor{
        require(msg.sender == Distributor, "Only the distributor can call this method.");
        _;
    }

    constructor(uint _maxSupply, uint _mintValue, uint[2] memory _publicKeyPoint, address _helper )ERC721("CryptoRicks", "CR"){
        Distributor = msg.sender;
        helper = VRFHelper(_helper);
        require(Distributor == helper.pointToAddress(_publicKeyPoint[0], _publicKeyPoint[1]), "Invalid Public Key Point for Distributor Address.");
        PublicKeyPointX = _publicKeyPoint[0];
        PublicKeyPointY = _publicKeyPoint[1];
        MaxSupply = _maxSupply;
        MintValue =_mintValue;
        _mint(msg.sender, 0);
    }

    function _baseURI() internal override view returns (string memory) {
        return BaseURI;
    }

    function setProofVariables(string memory _uri, bytes32 _root) public onlyDistributor{
        require(ProofVariables == false, "BaseURI and Root have already been set");
        //require(PublicKeyHash == keccak256(abi.encodePacked(_publicKey)), "Invalid public key given.");
        ProofVariables = true;
        BaseURI = _uri;
        //PublicKey = _publicKey;
        Root = _root;
        //PublicKeyPoint = helper.decodePoint(_publicKey);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }

    function mint(address _receiver) public payable mintable {
        TokenIds.increment();
        uint _id = TokenIds.current();
        _safeMint(_receiver, _id);
    }

    function claim() public onlyDistributor{
        (bool sent, ) = Distributor.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    /*
    function createLeaf(string memory _CID, bytes memory _message, bytes memory _vrfProof) public pure returns(bytes32){
        return keccak256(abi.encodePacked( _CID, _message, _vrfProof));
    }
    
    function verifyLeaf(bytes32[] memory _merkleProof, bytes32 _leaf) public view returns(bool _verified){

        return MerkleProof.verify(_merkleProof, Root, _leaf);
    }
    
    function verifyVRF(bytes memory _message, bytes memory _vrfProof) public view returns(bool _verified){
        uint[4] memory proof = helper.decodeProof(_vrfProof);
        return helper.verify(PublicKeyPoint, proof, _message);
    }*/

    function verify(bytes32[] memory _merkleProof, string memory _CID, bytes memory _vrfMessage, bytes memory _vrfProof) public view returns(bool _verified){
        bytes32 leaf = keccak256(abi.encodePacked(_CID, _vrfMessage, _vrfProof));
        require(MerkleProof.verify(_merkleProof, Root, leaf), "Invalid Merkle Proof");
        return helper.verify([PublicKeyPointX, PublicKeyPointY], helper.decodeProof(_vrfProof), _vrfMessage);
    }
}