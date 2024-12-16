// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Helper } from "../helper/Helper.sol";

// Contract For a sigle item purchase Shop
contract ShopV0 {

    // Address of the Onwer of the Shop
    address public immutable Owner;

    // Array of products.
    string[] public Products;
    
    // Mapping to hold information of the product with the given name.
    mapping(string => Product) public ProductsMap;

    // Variable to reference the Purchase made.
    uint public PurchaseID = 0;

    mapping(uint256 => Purchase) public Purchases;

    // Variable to hold USDC contract
    IERC20 public USDC;

    // Modifier to ensure the owner is calling the method.
    modifier onlyOwner(){
        require(msg.sender == Owner, "");
        _;
    }

    // Struct to hold Product Information.
    struct Product{
        uint256 price;
        uint256 inventory;
    }

    // Enum to define status of purchase.
    enum Status{
        purchased,
        shipped,
        revoked
    }

    // Struct to define a purchase.
    struct Purchase {
        uint256 id;
        address buyer;
        string name;
        string encrypted_ship;
        Status status;
    }

    // Event to emit that an item was Purchased.
    event Purchased(address _buyer, string _name, uint256 _id);

    // Constructor 
    constructor(string[] memory _product_name, Product[] memory _product_info, address _usdc){
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
        ProductsMap[_name] = Product(_price, _inventory);
    }

    /*
    * Function to modify a product in the shop.
    * @Param _name, name of the product.
    * @Param _price, price of the product.
    * @Param _inventory, inventory of the product.
    */
    function modifyProduct(string memory _name, uint _price, uint _inventory) public onlyOwner{
        require(ProductsMap[_name].price != 0, "The has not been added.");
        ProductsMap[_name] = Product(_price, _inventory);
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
    * @Param _encrypted_ship, the encrypted shipping information for the purchaser.
    */
    function purchase(string memory _name, string memory _encrypted_ship) public{
        require(ProductsMap[_name].price != 0 && ProductsMap[_name].inventory != 0, "Invalid product or inventory");
        require(USDC.allowance(address(this), msg.sender) >= ProductsMap[_name].price);
        USDC.transferFrom(msg.sender, address(this), ProductsMap[_name].price);
        ++PurchaseID;
        Purchases[PurchaseID] = Purchase(PurchaseID, msg.sender, _name, _encrypted_ship, Status.purchased);
        emit Purchased(msg.sender, _name, PurchaseID);
    }

    /* 
    *  Function to indicate an item has been shiped
    * @Param _id, id of the purchase
    */
    function ship(uint256 _id) public onlyOwner{
        Purchases[_id].status = Status.shipped;
    }

    /*
    * Function to revoke a perchase of the buyer
    * @Param _id, id of the purchase
    * @Param _amount, amount of USDC to be sent back to the buyer.
    */
    function revoke(uint _id, uint _amount) public onlyOwner{
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