// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { Helper } from "../helper/Helper.sol";

// Contract For A Shop
contract Shop {

    // Address of the Onwer of the Shop
    address public immutable Owner;

    // Array of products.
    string[] public Products;

    // Number of products
    uint public ProductCount; 
    
    // Mapping to hold information of the product with the given name.
    mapping(string => Product) public ProductsMap;

    // Variable to reference the Purchase made.
    uint public PurchaseID = 0;

    mapping(uint256 => Purchase) public Purchases;

    // Variable to hold USDC contract
    IERC20 public USDC;

    // Key used to encrypt shipping information
    Key public SignKey;

    // Hash for SignKey signature verification.
    bytes32 public EnableHash;

    // Modifier to ensure the owner is calling the method.
    modifier onlyOwner(){
        require(msg.sender == Owner, "");
        _;
    }
    
    // Struct to define owner key to encrypt shipping information.
    struct Key{
        bytes32 r;
        bytes32 s;
        uint8 v;
    }
        
    // Struct to hold Product Information.
    struct Product{
        uint256 id;
        uint256 price;
        uint256 inventory;
        uint256 holds;
        uint256 last_purchase;
    }

    // Enum to define status of purchase.
    enum Status{
        purchased,
        shipped,
        revoked
    }

    // Struct to define products to be purchased.
    struct Cart {
        string[] names;
        uint[] inventory;
        bool[] accepted;
        string encrypted_ship;
    }

    // Struct to define a purchase.
    struct Purchase {
        uint256 id;
        address buyer;
        Cart cart;
        Status status;
    }

    // Event to emit that an item was Purchased.
    event Purchased(address buyer, Cart cart, uint256 id);

    // Constructor 
    constructor(string[] memory _product_name, Product[] memory _product_info, address _usdc, bytes memory _signature){
        require(_product_name.length == _product_info.length, "Invalid initial product format");
        Owner = msg.sender;
        USDC = IERC20(_usdc);
        for(uint i = 0; i < _product_name.length; i++){
            _product_info[i].id = i;
            Products.push(_product_name[i]);
            ProductsMap[_product_name[i]] = _product_info[i];
        }
        ProductCount += _product_name.length;

        EnableHash = ECDSA.toEthSignedMessageHash(bytes("Enable Shipping"));

        require(SignatureChecker.isValidSignatureNow(msg.sender, EnableHash, _signature), "Invalid Signature");
        
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

        SignKey.r = _r;
        SignKey.s = _s;
        SignKey.v = _v;
    }

    /*
    * Function to add product to the Shop.
    * @Param _name, name of the product.
    * @Param _info, price and inventory of the product.
    */

   function addProduct(string calldata _name, Product calldata _info) public onlyOwner{
        require(ProductsMap[_name].price == 0, "The product has already been added.");
        require(_info.id == ProductCount + 1, "Invalid product id");
        Products.push(_name);
        ProductCount++;
   }

    /*
    * Function to add products to the Shop.
    * @Param _name, name of the product.
    * @Param _info, price and inventory of the product.
    */
    function addProducts(string[] calldata _names, Product[] calldata _info) public onlyOwner{
        require(_names.length == _info.length, "Invalid products format.");
        for(uint32 i = 0; i < _names.length; i++){
            require(ProductsMap[_names[i]].price == 0, "A product has already been added.");
            require(_info[i].id == ProductCount + i + 1, "Invalid product id");
        }
        for(uint32 i = 0; i < _names.length; i++){
            Products.push(_names[i]);
            ProductsMap[_names[i]] = _info[i];
        }
        ProductCount += _names.length;
    }

    /*
    * Function to modify a product in the shop.
    * @Param _name, name of the product.
    * @Param _info, price and inventory of the product.
    */
    function modifyProduct(string calldata _name, Product calldata _info) public onlyOwner{
        require(ProductsMap[_name].price != 0, "The product has not been added.");
        require(ProductsMap[_name].last_purchase == _info.last_purchase, "Cannot modify last purchase of product.");
        require(ProductsMap[_name].id == _info.id, "Cannot modify product id.");
        ProductsMap[_name] = _info;
    }

    /* 
    * Function to modify multiple products in the shop
    *   @Param _names, names of the products
    *   @Param _info, price and inventory of the products.
    * */
    function modifyProducts(string[] calldata _names, Product[] calldata _info) public onlyOwner{
        for(uint32 i = 0; i < _names.length; i++){
            require(ProductsMap[_names[i]].price != 0, "A product has not been added.");
            require(ProductsMap[_names[i]].last_purchase == _info[i].last_purchase, "Cannot modify last purchase of product.");
            require(ProductsMap[_names[i]].id == _info[i].id, "Cannot modify product id.");
        }
        for(uint32 i = 0; i < _names.length; i++){
            ProductsMap[_names[i]] = _info[i];
        }
    }

    /*
    * Function to remove a product from the shop.
    * @Param _name, name of the product
    * @Param _id, location of the product in the names array.
    */
    function removeProduct(string calldata _name) public onlyOwner{
        require(Helper.compareStrings(_name, Products[ProductsMap[_name].id]), "The id or name of the product to be removed was incorrect.");
        delete Products[ProductsMap[_name].id];
        delete ProductsMap[_name];
        
    }

    /*
    * Function to remove a product from the shop.
    * @Param _names, names of the product
    * @Param _ids, locations of the products in the names array.
    */
    function removeProducts(string[] calldata _names) public onlyOwner{
        for(uint32 i = 0; i < _names.length; i++){
            delete Products[ProductsMap[_names[i]].id];
            delete ProductsMap[_names[i]];
        }
    }

    /*
    * Function to purchase a product by the sender (buyer)
    * @Param _name, name of the product to purchase
    * @Param _encrypted_ship, the encrypted shipping information for the purchaser.
    */
    function purchase(Cart calldata _cart) public{
        uint totalCost = 0;
        require(_cart.names.length == _cart.inventory.length, "Invalid cart format (names don't match inventory).");
        require(_cart.accepted.length == 0, "Invalid cart format (accepted should be empty)");
        for(uint32 i = 0; i < _cart.names.length; i++){
            require(ProductsMap[_cart.names[i]].price != 0, "Invalid product price");
            require((ProductsMap[_cart.names[i]].inventory + ProductsMap[_cart.names[i]].holds) - _cart.inventory[i] >= 0, "");
            totalCost += (ProductsMap[_cart.names[i]].price * _cart.inventory[i]);
        }
        require(USDC.allowance(msg.sender, address(this)) >= totalCost);
        USDC.transferFrom(msg.sender, address(this), totalCost);

        for(uint32 i = 0; i < _cart.names.length; i++){
            ProductsMap[_cart.names[i]].holds += _cart.inventory[i];
        }

        ++PurchaseID;
        Purchases[PurchaseID] = Purchase(PurchaseID, msg.sender, _cart, Status.purchased);
        emit Purchased(msg.sender, _cart, PurchaseID);
    }

    /* 
    *  Function to indicate an item has been shiped
    * @Param _id, id of the purchase
    */
    function ship(uint256 _id, Cart calldata _cart) public onlyOwner{
        for(uint32 i = 0; i < _cart.accepted.length; i++){
            if(_cart.accepted[i] == true){
                ProductsMap[_cart.names[i]].inventory -= _cart.inventory[i]; 
            }
            ProductsMap[_cart.names[i]].holds -= _cart.inventory[i];
            ProductsMap[_cart.names[i]].last_purchase = block.number;
        }
        Purchases[_id].cart = _cart;        
        Purchases[_id].status = Status.shipped;
    }

    /*
    * Function to revoke a purchase of the buyer
    * @Param _id, id of the purchase
    * @Param _amount, amount of USDC to be sent back to the buyer.
    */
    function revoke(uint _id, Cart calldata _cart, uint256 _amount) public onlyOwner{
        for(uint32 i = 0; i < _cart.names.length; i++){
            ProductsMap[_cart.names[i]].holds -= _cart.inventory[i];
        }
        Purchases[_id].status = Status.revoked;
        USDC.transfer(Purchases[_id].buyer, _amount);
    }

    /*
    *   Function to claim revenue from contract. // called after potential revoke for efficiency.
    */
    function claim() public onlyOwner{
        USDC.transfer(Owner, USDC.balanceOf(address(this)));
    }
}