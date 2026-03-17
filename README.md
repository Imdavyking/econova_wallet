# 🌿 EcoNova Wallet

**EcoNova** is an AI-powered mobile wallet built for the **Stacks** ecosystem.
Instead of navigating complex crypto interfaces, you just talk to it —
EcoNova handles the fragmentation of multi-chain crypto through a single
natural language interface.

> Built for the Stacks Buidl Battle 2026

---

## 🤖 AI-First Design

EcoNova's core is a conversational AI agent that understands your intent
and executes on-chain actions autonomously:

- _"Send 10 STX to alice.btc"_
- _"Bridge my USDC to Stacks"_
- _"What's my sBTC balance?"_
- _"Pay for this API"_

No addresses. No gas confusion. No chain switching.

---

## 🚀 Features

### 💸 Token Transfers

Send and receive STX, sBTC, and USDCx through natural language or
traditional UI. Full SIP-010 contract call support built from scratch —
no stacks.js dependency.

### 🟠 sBTC Support

Hold and transfer sBTC — Bitcoin on Stacks. The AI understands
Bitcoin-denominated instructions and resolves them to sBTC operations.

### 💵 USDCx Support

Send and receive USDCx (Circle's USDC bridged to Stacks).
Spend in dollars, settle on Bitcoin.

### 🌉 USDC → USDCx Bridging

Bridge USDC from Ethereum directly to USDCx on Stacks via xReserve —
all from within the app. The AI handles the two-step approve + deposit
flow automatically.

### 🌐 BNS Resolution

Send to `.btc` names instead of raw addresses.
_"Send 5 STX to bob.btc"_ just works.

### ⚡ x402 Autonomous Payments

EcoNova supports the x402 HTTP payment protocol using STX, sBTC, and USDCx.
When the AI needs to access a paywalled API, it pays autonomously —
no human intervention required. The first mobile wallet where the AI
funds itself.

### 🔗 Multi-Chain, One Wallet

EcoNova also supports Ethereum, Base, Polygon, Arbitrum, Solana, and more.
Switch chains through conversation — no separate wallets needed.

### 📜 Transaction History

Track your STX, sBTC, and USDCx activity in one place.

---

## 🛠 Technical Highlights

- Custom Stacks transaction signing — RFC6979, SHA-512/256, SIP-010
  contract calls — all implemented natively in Flutter/Dart
- c32check address encoding ported from TypeScript
- x402 multi-version support (v0, v1, v2) with method-aware retry
- EIP-3009 signing for EVM x402 payments
- BNS resolution via Hiro API

---

Configure your `.env` with API keys.

---

## 🌿 Vision

Crypto has a fragmentation problem. EcoNova solves it with one sentence.
