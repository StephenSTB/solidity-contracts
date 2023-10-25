// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../helper/Helper.sol";

// Contract For a Shop
contract Shop {

    // Address of the Onwer of the Shop
    address public immutable Owner;

    // Array of products.
    string[] public Products;
    
    // Mapping to hold information of the product with the given name.
    mapping(string => ProductInfo) public ProductsMap;

    // Variable to reference the Purchase made.
    uint public PurchaseID = 0;

    // Array to reference the shipping informaton of a purchase.
    ShipInfo[] public ShipQueue;

    // Array to reference the purchases that were revoked.
    RevokeInfo[] public RevokeQueue;

    // Variable to hold USDC contract
    IERC20 public USDC;

    // Modifier to ensure the owner is calling the method.
    modifier onlyOwner(){
        require(msg.sender == Owner, "");
        _;
    }

    // Struct to hold Product Information.
    struct ProductInfo{
        uint price;
        uint inventory;
    }

    // Struct to hold Shipping Information.
    struct ShipInfo{
        address buyer;
        string name;
        string encrypted_ship;
    }

    // Struct to hold Revoked Information
    struct RevokeInfo{
        address buyer;
        string name;
        string encrypted_ship;
        uint purchase_id;
        uint amount;
    }

    // Constructor 
    constructor(string[] memory _product_name, ProductInfo[] memory _product_info, address _usdc){
        require(_product_name.length == _product_info.length, "Invalid initial product format");
        Owner = msg.sender;
        USDC = IERC20(_usdc);
        for(uint i = 0; i < _product_name.length; i++){
            Products.push(_product_name[i]);
            ProductsMap[_product_name[i]] = _product_info[i];
        }
    }

    /*
    * Function to add a product to the Shop.
    * @Param _name, name of the product.
    * @Param _price, price of the product.
    * @Param _inventory, initial inventory of the product.
    */
    function addProduct(string memory _name, uint _price, uint _inventory) public onlyOwner{
        require(ProductsMap[_name].price == 0, "The product has already been added.");
        Products.push(_name);
        ProductsMap[_name] = ProductInfo(_price, _inventory);
    }

    /*
    * Function to modify a product in the shop.
    * @Param _name, name of the product.
    * @Param _price, price of the product.
    * @Param _inventory, inventory of the product.
    */
    function modifyProduct(string memory _name, uint _price, uint _inventory) public onlyOwner{
        require(ProductsMap[_name].price != 0, "The has not been added.");
        ProductsMap[_name] = ProductInfo(_price, _inventory);
    }

    /*
    * Function to remove a product from the shop.
    * @Param _name, name of the product
    */
    function removeProduct(string memory _name, uint _id) public onlyOwner{
        require(Helper.compareStrings(_name, Products[_id]), "The id or name of the product to be removed was incorrect.");
        delete Products[_id];
        delete ProductsMap[_name];
    }

    /*
    * Function to purchase a product by the sender (buyer)
    * @Param _name, name of the product to purchase
    */
    function purchase(string memory _name, string memory _encrypted_ship) public{
        require(ProductsMap[_name].price != 0 && ProductsMap[_name].inventory != 0, "Invalid product or inventory");
        require(USDC.allowance(address(this), msg.sender) >= ProductsMap[_name].price);
        USDC.transferFrom(msg.sender, address(this), ProductsMap[_name].price);
        PurchaseID++;
        ShipQueue.push(ShipInfo(msg.sender, _name, _encrypted_ship));
    }

    /*
    * Function to revoke a perchase of the buyer
    * @Param _buyer, buyer of the product (incorrect purchaser)
    * @Param _name, of the product purchased.
    */
    function revoke(uint _id, uint _amount) public onlyOwner{
        RevokeQueue.push(RevokeInfo(ShipQueue[_id].buyer, ShipQueue[_id].name, ShipQueue[_id].encrypted_ship, _id, _amount));
        USDC.transfer(ShipQueue[_id].buyer, _amount);
    }

    /*
    *   Function to claim revenue from contract. // called after potential revoke for efficiency.
    */
    function claim() public onlyOwner{
        USDC.transfer(Owner, USDC.balanceOf(address(this)));
    }
}