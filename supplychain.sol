// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SupplyChain
 * @dev A supply chain management contract that allows the owner to add, update, manage, and sell products.
 */
contract SupplyChain {

    uint256 public latestProductId = 1;

    // Enum to represent the product and purchase status
    enum Status { SoldOut, Created, Ordered, Shipped, Delivered }

    // Struct to represent products in the supply chain
    struct Product {
        string name;
        string imageIPFS;
        uint256 price;
        uint256 quantity;
        Status status;
        bool exists;
        string description;
        address[] buyer;
    }

    // Struct to represent a purchase
    struct Purchase {
        uint256 quantity;
        Status status;
    }

    // Mapping of product ID to Product struct
    mapping(uint256 => Product) public products;

    // Mapping to track each user's purchases of a specific product
    mapping(address => mapping(uint256 => Purchase)) public purchases;

    // Events for logging actions
    event ProductAdded(uint256 indexed productId, string name, uint256 price, uint256 quantity, address indexed addedBy);
    event ProductUpdated(uint256 indexed productId, uint256 price, uint256 quantity, Status status, address indexed updatedBy);
    event ProductPurchased(uint256 indexed productId, uint256 quantity, address indexed buyer, uint256 totalPrice);
    event PurchaseStatusUpdated(uint256 indexed productId, address indexed buyer, Status status);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    address public owner;

    /**
     * @dev Constructor to initialize ownership.
     */
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev Adds a new product to the supply chain.
     * @param name Name of the product.
     * @param quantity Initial quantity of the product.
     * @param price Price of the product.
     */
    function addProduct(
        string memory name,
        string memory imageIPFS,
        uint256 quantity,
        uint256 price,
        string memory description
    ) external onlyOwner {
        require(!products[latestProductId].exists, "Product already exists");
        require(bytes(name).length > 0, "Product name cannot be empty");
        require(price > 0, "Price must be greater than zero");
        require(quantity > 0, "Quantity must be greater than zero");

        // Initialize the buyer array as an empty array
        address[] memory buyerArray;

        products[latestProductId] = Product(name, imageIPFS, price, quantity, Status.Created, true, description, buyerArray);
        emit ProductAdded(latestProductId, name, price, quantity, msg.sender);

        latestProductId = latestProductId + 1;
    }

    /**
     * @dev Allows the owner to update the quantity of an existing product.
     * @param productId Identifier of the product to update.
     * @param quantity New quantity of the product.
     */
    function updateProductQuantity(uint256 productId, uint256 quantity) external onlyOwner {
        require(products[productId].exists, "Product does not exist");
        products[productId].quantity = quantity;
        products[productId].status = Status.Created;

        emit ProductUpdated(productId, products[productId].price, quantity, products[productId].status, msg.sender);
    }

    /**
     * @dev Updates the status of a product if soldOut or not available.
     * @param productId Identifier of the product.
     * @param status New status to set PRODUCT AVAILABILITY TO SOLDOUT OR CREATED.
     */
    function updateProductAvailability(uint256 productId, Status status) external onlyOwner {
        require(products[productId].exists, "Product does not exist");
        products[productId].status = status;

    }

    /**
     * @dev Allows users to purchase a product by paying the required amount.
     * @param productId Identifier of the product.
     * @param quantity Quantity to purchase.
     */
    function purchaseProduct(uint256 productId, uint256 quantity) external payable {
        require(products[productId].exists, "Product does not exist");
        require(products[productId].status == Status.Created, "Product is not available for purchase");
        require(quantity > 0 && quantity <= products[productId].quantity, "Invalid quantity");
        
        uint256 totalPrice = products[productId].price * quantity;
        require(msg.value >= totalPrice, "Insufficient payment");

        // Deduct the purchased quantity from available stock
        products[productId].quantity -= quantity;

        if (products[productId].quantity == 0) {
            products[productId].status = Status.SoldOut;
        }

        // Track the user's purchased quantity and set status to Created
        purchases[msg.sender][productId] = Purchase(quantity, Status.Ordered);

        // Add buyer's address to the product's buyer list
        products[productId].buyer.push(msg.sender);

        // Refund any excess payment
        if (msg.value > totalPrice) {
            (bool refundSuccess, ) = msg.sender.call{value: msg.value - totalPrice}("");
            require(refundSuccess, "Refund failed");
        }

        emit ProductPurchased(productId, quantity, msg.sender, totalPrice);
    }

    /**
     * @dev Updates the status of a specific user's purchase.
     * @param productId Identifier of the product.
     * @param buyer Address of the buyer.
     * @param status New status to set for the buyer's purchase.
     */
    function updatePurchaseStatus(uint256 productId, address buyer, Status status) external onlyOwner {
        require(products[productId].exists, "Product does not exist");
        require(purchases[buyer][productId].quantity > 0, "No purchase found for this buyer");

        // Update the purchase status
        purchases[buyer][productId].status = status;

        emit PurchaseStatusUpdated(productId, buyer, status);
    }

    /**
     * @dev Withdraws all Ether from the contract to the owner's address.
     */
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");

        emit FundsWithdrawn(owner, balance);
    }

    /**
     * @dev Returns the quantity and status of a product purchased by a specific buyer.
     * @param buyer Address of the buyer.
     * @param productId Identifier of the product.
     * @return Quantity purchased and current status.
     */
    function getPurchasedDetails(address buyer, uint256 productId) external view returns (uint256, Status) {
        Purchase memory purchase = purchases[buyer][productId];
        return (purchase.quantity, purchase.status);
    }

    /**
    * @dev Returns the list of all buyers for a specific product.
    * @param productId Identifier of the product.
    * @return List of addresses that purchased the product.
    */
    function getProductBuyers(uint256 productId) external view returns (address[] memory) {
        require(products[productId].exists, "Product does not exist");
        return products[productId].buyer;
    }

    function transferOwnership(address newOwner)external onlyOwner {
        owner = newOwner;
    }

    /**
     * @dev Fallback function to accept Ether.
     */
    receive() external payable {}

    /**
     * @dev Fallback function to handle unexpected calls.
     */
    fallback() external payable {}
}
