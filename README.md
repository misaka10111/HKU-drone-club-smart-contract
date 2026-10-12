# HKU Drone Club Smart Contracts

A Solidity project for the COMP7610B Smart Contract Lab, deployed on the Sepolia testnet.

## Features

- **ClubPoints (CPT):** ERC-20 token with an initial supply of 1,000 CPT. Only the administrator can mint additional points or call the distribution function.
- **CampusMemo:** ERC-721 commemorative NFTs, limited to 10. Each NFT costs 100 CPT, which are burned during redemption.
- **Daily check-in:** Each address can claim 10 CPT every 24 hours from an administrator-funded pool. The administrator can enable or disable claims.

## Deployment

Compile in [Remix](https://remix.ethereum.org/) with Solidity **0.8.24**, OpenZeppelin **5.0.2**, EVM **Shanghai**, and optimization enabled (**200 runs**).

1. Connect MetaMask to Sepolia and deploy `ClubPoints`.
2. Deploy `CampusMemo` with the CPT contract address and a public NFT metadata JSON URI.
3. Keep the transaction value at **0 wei**; test ETH is needed for gas.

## Usage

1. Administrator: call `distribute(member, amount)` on ClubPoints.
2. Member: call `approve(nftAddress, 100000000000000000000)` on ClubPoints, then `mintMemo()` on CampusMemo.
3. To enable rewards, the administrator transfers CPT to CampusMemo and calls `setCheckInEnabled(true)`. Members can then call `dailyCheckIn()`.

All CPT amounts use 18 decimals: **1 CPT = 10^18 units**.

## Sepolia Contracts

| Contract | Address |
|---|---|
| ClubPoints | [`0x6826A103dB8e2532AB13aaC4C19c7a5439214a9C`](https://sepolia.etherscan.io/address/0x6826A103dB8e2532AB13aaC4C19c7a5439214a9C) |
| CampusMemo | [`0xC89DFC78537eB906536268f49BF773d57c8667AB`](https://sepolia.etherscan.io/address/0xC89DFC78537eB906536268f49BF773d57c8667AB) |

[NFT metadata](https://gist.githubusercontent.com/misaka10111/1a894e71bb6125324fa9e4591f3c18f9/raw/680cb6d220c7afcd75187f03de0e402ecdeab9d9/campus-memo.json)

Created for educational use on Sepolia.
