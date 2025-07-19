# 🏠 RentSure – Decentralized Rental Agreement & Security Deposit Escrow

RentSure is a Web3-based platform that enables **trustless rental agreements**, **secure deposit management**, and **decentralized dispute resolution** between landlords and tenants. It leverages smart contracts to eliminate the need for centralized intermediaries in the rental market.

---

## 🚀 Features

- ✍️ On-chain rental agreements with EIP-712 signatures
- 🔒 Secure deposit escrow using smart contracts
- ⏳ Automatic deposit release after lease ends (unless disputed)
- ⚖️ Dispute resolution via decentralized arbitrators or DAO voting
- 🪪 Optional reputation NFTs for tenants and landlords

---

## 🧱 Smart Contracts

### 1. `RentalAgreement.sol`
- Deploys a new agreement for each landlord-tenant pair.
- Tracks:
  - Parties involved
  - Rental terms (start date, end date, rent amount)
  - Status (`Active`, `Completed`, `Terminated`, `Disputed`)
- Accepts EIP-712 signatures for off-chain signing.

### 2. `DepositEscrow.sol`
- Handles:
  - Receiving security deposits (in stablecoins like USDC/DAI)
  - Releasing deposits to the correct party based on contract status
- Integrates with RentalAgreement to lock/unlock funds.

### 3. `DisputeResolver.sol` (Optional)
- Enables decentralized dispute resolution:
  - DAO/community voting
  - Assigned arbitrators
- Updates agreement outcome based on resolution result.

---

## 🛠️ Tech Stack

| Layer         | Tech                           |
|---------------|--------------------------------|
| Blockchain    | Ethereum / Base / Polygon      |
| Contracts     | Solidity (Hardhat)             |
| Frontend      | Next.js + Wagmi + RainbowKit   |
| Storage       | IPFS (for optional documents)  |
| Oracles       | Chainlink Keepers (automation) |

---

## 🔄 User Flow

### 🧍 Tenant
1. Reviews rental agreement details.
2. Signs digitally (EIP-712).
3. Sends deposit to escrow contract.

### 🧍‍♂️ Landlord
1. Signs agreement.
2. Confirms lease start.
3. Can initiate claim against deposit if needed.

### ⚖️ Dispute (optional)
- Triggered by tenant or landlord.
- Arbiters vote.
- Deposit is distributed based on result.

---

## 📦 Installation

```bash
git clone https://github.com/yourusername/rentsure.git
cd rentsure
yarn install
