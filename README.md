# NFT Collection

A fully functional ERC-721 compatible NFT smart contract with comprehensive automated test suite and Docker support.

## Overview

This project implements an ERC-721 compatible NFT smart contract designed for the Partnr Global Placement Program. The implementation includes:

- **Smart Contract**: A feature-rich NFT contract implementing core ERC-721 functionality
- **Test Suite**: Comprehensive automated tests covering all contract behaviors
- **Docker Support**: Containerized environment for reproducible testing

## Features

### Smart Contract (NftCollection.sol)

- **ERC-721 Compatibility**: Full implementation of the ERC-721 standard interface
- **Minting**: Admin-controlled token minting with validation
- **Transfers**: Safe transfer functionality with authorization checks
- **Approvals**: Individual token approval and operator approval mechanisms
- **Metadata**: Token metadata URI support
- **Burning**: Token burning capability
- **Pausing**: Emergency pause/unpause functionality
- **Access Control**: Admin-based access control for privileged operations

### Test Coverage

The test suite includes tests for:

- Deployment and initialization
- Minting (successful, unauthorized, double-mint prevention)
- Balance tracking and ownership
- Transfers (authorized, unauthorized, zero-address validation)
- Approvals and operator approvals
- Metadata and URI handling
- Pause/unpause functionality
- Token burning
- Gas efficiency
- Edge cases and consistency checks

## Project Structure

```
.
├── contracts/
│   └── NftCollection.sol       # Main ERC-721 contract
├── test/
│   └── NftCollection.test.js   # Comprehensive test suite
├── package.json                 # Project dependencies
├── hardhat.config.js           # Hardhat configuration
├── Dockerfile                   # Docker containerization
└── README.md                   # This file
```

## Getting Started

### Prerequisites

- Node.js 18.x or later
- npm or yarn
- Docker (for containerized testing)

### Installation

```bash
npm install
```

### Running Tests Locally

```bash
npm test
```

### Building the Smart Contract

```bash
npm run compile
```

## Docker Usage

Build the Docker image:

```bash
docker build -t nft-collection .
```

Run tests in Docker:

```bash
docker run nft-collection
```

The Docker container automatically runs the complete test suite and produces clear output showing test results.

## Contract Details

### State Variables

- `name`: "NFT Collection"
- `symbol`: "NFT"
- `maxSupply`: 10,000 tokens
- `totalSupply`: Current number of minted tokens
- `baseURI`: Metadata base URL for token URIs

### Key Functions

- `mint(address to, uint256 tokenId)`: Mint a new token (admin only)
- `burn(uint256 tokenId)`: Burn a token
- `transferFrom(address from, address to, uint256 tokenId)`: Transfer a token
- `safeTransferFrom()`: Safe transfer with receiver validation
- `approve(address to, uint256 tokenId)`: Approve token transfer
- `setApprovalForAll(address operator, bool approved)`: Approve all tokens
- `balanceOf(address owner)`: Get token balance
- `ownerOf(uint256 tokenId)`: Get token owner
- `tokenURI(uint256 tokenId)`: Get token metadata URI
- `pause()/unpause()`: Emergency pause functionality

## Testing

The test suite uses Hardhat and Chai for comprehensive testing:

- **Deployment Tests**: Verify correct initialization
- **Minting Tests**: Validate minting logic and restrictions
- **Transfer Tests**: Ensure correct ownership and balance changes
- **Approval Tests**: Verify approval mechanisms
- **Metadata Tests**: Test URI generation and metadata
- **Security Tests**: Validate authorization and access control
- **Gas Efficiency**: Ensure reasonable gas usage

## Gas Considerations

The contract is optimized for reasonable gas usage:

- Simple state management with mappings
- Direct storage access without unnecessary iterations
- Efficient ownership tracking
- Minimal storage overhead

## Security Features

- **Access Control**: Admin-based authorization for sensitive operations
- **Input Validation**: Zero-address checks and token existence validation
- **State Consistency**: Atomic operations preventing partial state updates
- **Safe Transfers**: ERC-721 receiver validation for safe transfers
- **Reentrancy Prevention**: No external calls vulnerable to reentrancy

## Future Enhancements

Possible improvements:

- ERC-721 Enumerable extension for token discovery
- Royalty support (ERC-2981)
- Whitelist/allowlist functionality
- Dynamic metadata generation
- Multi-signature admin approval

## License

MIT License - See LICENSE file for details

## Support

For questions or issues, please refer to the test suite for usage examples and expected behavior.
