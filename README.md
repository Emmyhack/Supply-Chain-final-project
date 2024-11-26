# SupplyChain Smart Contract

## Overview

The `SupplyChain` contract is a decentralized application built on the Ethereum blockchain that facilitates the management of products within a supply chain. It allows the owner to add, update, manage, and sell products while tracking purchases made by buyers. This contract provides a transparent and efficient way to handle product availability, sales, and buyer interactions.

## Features

- **Product Management**: Add, update, and manage products.
- **Purchasing System**: Users can purchase products with Ether, with automatic handling of excess payments.
- **Purchase Tracking**: Track each user's purchase details, including quantity and status.
- **Event Logging**: Important actions are logged through events for transparency.
- **Funds Withdrawal**: The owner can withdraw funds collected from product sales.

## Contract Structure

### Enums

- **Status**: Represents the status of a product or purchase.
  - `SoldOut`
  - `Created`
  - `Ordered`
  - `Shipped`
  - `Delivered`

### Structs

- **Product**: Represents a product in the supply chain.
  - `name`: Name of the product.
  - `imageIPFS`: IPFS link for the product image.
  - `price`: Price of the product.
  - `quantity`: Available quantity of the product.
  - `status`: Current status of the product.
  - `exists`: Boolean indicating if the product exists.
  - `description`: Description of the product.
  - `buyer`: List of buyers who purchased the product.

- **Purchase**: Represents a purchase made by a buyer.
  - `quantity`: Number of products purchased.
  - `status`: Current status of the purchase.

### State Variables

- `latestProductId`: Tracks the latest product ID.
- `products`: Mapping of product IDs to `Product` structs.
- `purchases`: Mapping of user addresses to their purchases.
- `owner`: Address of the contract owner.

### Events

- `ProductAdded`: Emitted when a new product is added.
- `ProductUpdated`: Emitted when a product is updated.
- `ProductPurchased`: Emitted when a product is purchased.
- `PurchaseStatusUpdated`: Emitted when a purchase status is updated.
- `FundsWithdrawn`: Emitted when funds are withdrawn by the owner.

## Functions

### Owner Functions

- `addProduct`: Adds a new product to the supply chain.
- `updateProductQuantity`: Updates the quantity of an existing product.
- `updateProductAvailability`: Updates the availability status of a product.
- `updatePurchaseStatus`: Updates the status of a specific user's purchase.
- `withdrawFunds`: Withdraws all Ether from the contract to the owner's address.
- `transferOwnership`: Transfers ownership of the contract to a new address.

### User Functions

- `purchaseProduct`: Allows users to purchase a product by sending Ether.
- `getPurchasedDetails`: Returns the quantity and status of a product purchased by a specific buyer.
- `getProductBuyers`: Returns the list of all buyers for a specific product.

### Fallback Functions

- `receive`: Accepts Ether sent to the contract.
- `fallback`: Handles unexpected calls to the contract.

## Usage

1. **Deploy the Contract**: Deploy the `SupplyChain` contract on the Ethereum network.
2. **Add Products**: The owner can call `addProduct` to add new products to the supply chain.
3. **Purchase Products**: Users can call `purchaseProduct` to buy available products.
4. **Manage Products**: The owner can update product details and manage purchases as needed.

## Requirements

- Solidity version: `^0.8.0`
- Compatible Ethereum network (e.g., Ethereum mainnet, testnets).

## License

This contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any changes or improvements.

## Acknowledgments

We would like to thank the Ethereum community for their support and resources that made the development of this contract possible. Special thanks to the developers and contributors who have shared their knowledge and tools for building decentralized applications.
