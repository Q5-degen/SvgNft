# SvgNft: A Dynamic NFT Project with Chainlink Automation

**Author:** selone te

## 📜 Overview

Welcome to SvgNft! This is a simple yet powerful NFT project that demonstrates the capabilities of Chainlink Automation to create dynamic and interactive NFTs on the Ethereum SEPOLIA blockchain.

The core idea is to have an NFT that can be in one of two states: "Happy" or "Sad".

- **Happy NFT**: This is the initial state of the NFT that a user can mint.
- **Sad NFT**: If a user decides to burn their "Happy" NFT, a Chainlink Automation Log Trigger will detect this on-chain event and automatically mint a new "Sad" NFT to the user's wallet.

This project showcases how smart contracts can react to on-chain events in a decentralized and automated manner.

## ✨ Features

- **ERC721 Compliant**: A standard and interoperable NFT contract.
- **Dynamic SVGs**: The image of the NFT changes based on its state.
- **Chainlink Automation**: Utilizes Chainlink's Log Trigger to automate the minting of the "Sad" NFT after a burn event.
- **One NFT Per Wallet**: To keep things simple, each wallet can only hold one SvgNft at a time.

## 🚀 Getting Started

### Prerequisites

- [MetaMask](https://metamask.io/) or a similar wallet installed.
- ETH on a test network (e.g., Sepolia) to pay for gas fees and the mint price.

### How to Mint a "Happy" NFT

1. **Connect Your Wallet**: Connect your wallet to the application.
2. **Mint**: Call the `mint()` function and send the required `mintPrice` in ETH. You can also send ETH directly to the contract address to trigger the minting process.

### How to Get a "Sad" NFT

1. **Burn Your "Happy" NFT**: If you own a "Happy" NFT, call the `burn()` function with the `tokenId` of your NFT.
2. **Automation Magic**: Once the `burn()` transaction is confirmed, a Chainlink Automation will be triggered.
3. **Receive Your "Sad" NFT**: The automation will call the `performUpkeep()` function in the contract, which will mint a new "Sad" NFT and send it to your wallet.

## 🤖 Chainlink Automation Explained

This project uses a **Log Trigger** from Chainlink Automation. Here's how it works:

1. **Event Emission**: When the `burn()` function is successfully executed, it emits an `NftBurner` event containing the address of the former owner.
2. **Log Monitoring**: A Chainlink Automation is configured to monitor the logs for this specific `NftBurner` event.
3. **Upkeep Check**: The `checkLog()` function in the contract is called by the Chainlink network. It decodes the event log and determines that an action (an "upkeep") is needed.
4. **Perform Upkeep**: If `checkLog()` returns `true`, the Chainlink Automation calls the `performUpkeep()` function, passing the address of the burner as `performData`.
5. **New NFT Minted**: The `performUpkeep()` function then mints a new "Sad" NFT to the burner's address.

## 🔧 For Developers

### Contract Details

- **`mint()`**: Mints a "Happy" NFT.
- **`burn(uint256 _tokenId)`**: Burns an NFT and emits the `NftBurner` event.
- **`checkLog(Log memory log, ...)`**:  The function that Chainlink Automation calls to check if an upkeep is needed.
- **`performUpkeep(bytes memory performData)`**: The function that Chainlink Automation calls to perform the upkeep (minting the "Sad" NFT).
- **`tokenURI(uint256 _tokenId)`**: Returns the metadata URI, which will point to either the "Happy" or "Sad" SVG image.


### Installation

1.  **Clone your repository:**
    ```bash
    git clone https://github.com/Q5-degen/SvgNft.git
    cd CharityFactory
    ```
