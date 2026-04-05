# EcoNova Wallet

> **One wallet. Every chain. One conversation.**

EcoNova is an AI-powered multi-chain mobile wallet built **Starknet-first** and extended across 30+ blockchains. Instead of navigating complex crypto interfaces, you just talk to it — EcoNova understands your intent and executes on-chain actions autonomously.

No chain-switching. No ABI reading. No address copying.

---

## The Problem

Crypto in 2026 is still hard. Not because the technology isn't ready — because the interface never caught up.

A typical user wanting to save stablecoins and earn yield needs to:

1. Find a compatible wallet
2. Bridge assets through separate protocols
3. Navigate unfamiliar DeFi interfaces
4. Confirm transactions they don't fully understand
5. Track activity across multiple explorers
6. Repeat everything on mobile — often with limited support

This is the everyday reality. Not just for beginners — for experienced users. Most people don't fully use DeFi, not because it's bad, but because the friction is too high.

**EcoNova removes that friction entirely.**

---

## Why Starknet First

Starknet is one of the most promising ZK-rollup Layer 2s on Ethereum — offering zero-knowledge security, near-zero fees, and blazing performance. Yet it lacks user-friendly wallets that abstract away its complexity.

EcoNova is purpose-built for that gap: a Starknet-native wallet that feels as simple as a chat app, backed by the full depth of Starknet's capabilities — staking, DeFi, meme coin deployment, domain resolution, and more.

---

## AI-First Design

EcoNova's core is a conversational AI agent that understands your intent and executes on-chain actions:

```
"Send 10 STRK to Alice"
"Send $10 worth of crypto to Mum"       ← fetches live price & calculates
"Save 5 USDC to my holiday fund"
"Show my savings goals"
"Withdraw all from my savings"
"What's my BTC balance?"
"Swap $20 ETH to USDC"
"Stake 50 STRK"
"Deploy a meme coin on Starknet"
```

The AI parses your command, resolves contacts and domain names, fetches live prices where needed, and submits the transaction — all in one step.

---

## Features

### 🎙️ Voice Recognition
Hands-free wallet control on mobile. Execute transfers, swaps, and queries by speaking naturally.

### 👥 Saved Contacts
Save trusted addresses once, send using names. *"Send $20 ETH to Wisdom"* or *"Send STRK to Mom"* — no address memorisation required.

### 💵 Savings Goals
A built-in savings system powered by smart contracts. Create named goals, deposit stablecoins incrementally, and withdraw anytime — no lockups or penalties. Progress tracking and full transaction history included.

### 💸 Token Transfers & Swaps
Send, receive, and swap tokens via natural language or traditional UI. Supports all major token standards across every supported chain.

### 📈 Portfolio Overview
Real-time unified view of all holdings across all assets and networks in one dashboard.

### ⛓️ Staking
Stake tokens and earn rewards through integrated staking protocols directly from the wallet.

### 🌐 Domain Name Resolution
Send to human-readable names instead of raw addresses — `fricoben.stark`, `vitalik.eth`, `foundation.sol` — across all supported naming services.

### 🐸 Meme Coin Deployment
Deploy your own token on Starknet in minutes. No coding required.

### 💧 Liquidity Management
Add or remove liquidity and manage DeFi positions effortlessly.

### 🧭 dApp Browser

Access any dApp directly inside EcoNova with injected wallet providers:

| Chain    | Compatibility              |
|----------|----------------------------|
| Starknet | Argent / Braavos compatible |
| EVM      | MetaMask compatible        |
| Solana   | Phantom compatible         |
| NEAR     | Wallet selector compatible |
| MultiversX | Native provider          |

### ⚡ Autonomous Payments
Automated payments for APIs and paywalled services. Multi-token support, automatic retry, no manual intervention needed.

### 📚 Documentation Search
Search Starknet documentation and developer references from within the app.

### 📜 Transaction History
Full history across all chains in one place.

---

## Bitcoin Support

EcoNova derives native Bitcoin keys from the same seed — no separate wallet needed:

| Type            | Format                    | Capability        |
|-----------------|---------------------------|-------------------|
| P2WPKH (SegWit) | `bc1q...` / `tb1q...`    | Send + Receive    |
| P2TR (Taproot)  | `bc1p...` / `tb1p...`    | Receive           |

---

## Security

### SLIP39 Seed Splitting
Split your seed into multiple shares (K-of-N threshold). Human-readable word lists, optional passphrase, and hardware wallet compatibility. Lose any subset of shares — your funds remain safe.

### Dead Man's Switch
A built-in inheritance mechanism. Set a time-lock, nominate a beneficiary, and distribute encrypted shares. If you go silent, your assets transfer automatically. Forward secrecy maintained via periodic updates.

### Native Cryptography — Pure Dart
All cryptographic primitives implemented from scratch, with no native dependencies:

- ECIES (secp256k1)
- AES-256-GCM
- HMAC-SHA256
- HKDF
- Shamir Secret Sharing
- SLIP39 encoding

Runs identically on iOS, Android, and desktop.

---

## Supported Chains

EcoNova is built Starknet-first and extended across 30+ networks:

| Category | Chains |
|----------|--------|
| **Starknet** | Native L2 — primary focus |
| **EVM** | Ethereum, BNB Chain, Polygon, Avalanche, Arbitrum, Optimism, Base, and ~10 more |
| **Move** | Aptos, Sui |
| **Solana** | SPL token support included |
| **Cosmos** | IBC universe, multiple Cosmos chains |
| **Polkadot** | DOT, KSM, parachain ecosystem |
| **TON** | Telegram-native blockchain |
| **TRON** | TRC token support |
| **NEAR** | NEP-141 fungible tokens |
| **MultiversX** | EGLD and ESDT tokens |
| **Bitcoin** | Native SegWit and Taproot |
| **Others** | XRP, Stellar, Filecoin, Zilliqa, Harmony, IOTEX, Ronin, FUSE, Stacks, ICP, Algorand, Tezos, and more |

**Token standards supported:** ERC20, TRC20, SPL, NEP-141, ESDT, SIP-010, FUSEFT, and all major fungible token formats.

---

## Wallet Import

| Format         | Example              |
|----------------|----------------------|
| BIP39 mnemonic | `abandon ability...` |
| Raw seed hex   | `7e9f86...`          |
| Keystore JSON  | `{ "version": 3 }`   |

All formats normalise into a unified internal representation.

---

## Getting Started

**Requirements:** Flutter 3.24.1 · Dart 3.5.1

```bash
# 1. Clone the repository
git clone https://github.com/Imdavyking/econova_wallet
cd econova_wallet

# 2. Install dependencies
flutter pub get

# 3. Configure environment
cp .env.example .env
# Add your OPENAI_API_KEY to .env

# 4. Run
flutter run
```

> Never commit `.env`. Use secure storage for all API keys.

---

## Market Opportunity

| Segment | Opportunity |
|---------|-------------|
| Crypto wallets | $48B market by 2030 (up from $8.4B in 2022) |
| Starknet ecosystem | First-mover advantage in L2-native UX |
| AI-powered UX | Early-stage, high-demand differentiator |
| Multi-chain integration | Solving wallet fragmentation |
| Bitcoin adoption | Increasing global demand |
| Security solutions | High-value differentiation |
| Retail onboarding | Growing demand for simplified interfaces |

The combination of Starknet's growth trajectory, multi-chain fragmentation, and the absence of truly simple crypto UX creates a clear opening. EcoNova is positioned at that intersection.

---

## Contributing

Contributions from developers, designers, and crypto enthusiasts are welcome.

- Found a bug? [Open an issue](https://github.com/Imdavyking/econova_wallet/issues)
- Have a feature idea? Submit a PR
- Want to discuss roadmap priorities — voice control, new chains, AI improvements? Start a discussion

---

## Vision

Crypto has a fragmentation problem. Dozens of chains, dozens of wallets, and an interface that still assumes you know what a gas limit is.

EcoNova solves it in one sentence:

**One wallet. Every chain. One conversation.**