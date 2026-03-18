# 🌿 EcoNova Wallet

**EcoNova** is an AI-powered mobile wallet built for the **Stacks** ecosystem.
Instead of navigating complex crypto interfaces, you just talk to it —
EcoNova handles the fragmentation of multi-chain crypto through a single
natural language interface.

> Built for the **Stacks Buidl Battle 2026**.

---

## 🏆 Bounty Alignment

EcoNova is a direct submission for all three Buidl Battle bounties:

| Bounty                             | How EcoNova qualifies                                                                                                                                                                                           |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🥇 **Best Use of USDCx**           | Native USDCx send/receive + Clarity 2 savings goals vault — users create named saving plans, deposit USDCx incrementally, and track progress. All built without stacks.js.                                      |
| 🥇 **Most Innovative Use of sBTC** | First mobile wallet with native sBTC support. Send, receive, and hold sBTC through a conversational AI interface. No browser extension needed.                                                                  |
| 🥇 **Best x402 Integration**       | The AI pays for paywalled APIs autonomously using STX, sBTC, or USDCx via x402. Multi-version (v0/v1/v2), separate signing paths for STX and SIP-010 tokens. The first mobile wallet where the AI funds itself. |

---

## 🔴 The Problem

Crypto in 2026 is still hard. Not because the technology isn't ready —
because the **interface** never caught up.

A typical Stacks user wanting to save USDC and earn yield needs to:

1. Find a Stacks-compatible wallet
2. Bridge USDC to USDCx through a separate protocol
3. Navigate a DeFi dApp with an unfamiliar UI
4. Confirm a contract call they don't fully understand
5. Track the transaction across two explorers
6. Repeat this on mobile — where almost no Stacks wallets exist

This is the everyday reality. Not for beginners — for experienced users.

**The result:** most people don't use Stacks DeFi. Not because it's bad.
Because the friction is too high.

EcoNova removes that friction entirely. You open the app, say what you want,
and it happens. No chain-switching. No ABI reading. No address copying.

---

## 🟠 Stacks — First Citizen

Everything in EcoNova is built Stacks-first. The entire Stacks signing stack
is implemented natively in Flutter/Dart with zero JavaScript dependencies —
RFC 6979 deterministic ECDSA, SHA-512/256, SIP-010 contract calls,
c32check address encoding, and BNS resolution all ported from scratch.

### 💠 STX Transfers

Send and receive STX natively. Full two-phase signing (pre-sign hash pattern
matching `@stacks/transactions` exactly), memo support, and automatic nonce

- fee fetching from the Hiro API.

### 🟡 sBTC _(Most Innovative Use of sBTC bounty)_

Hold and transfer sBTC — Bitcoin on Stacks. The AI understands
Bitcoin-denominated instructions and maps them to sBTC operations.
EcoNova is one of the first mobile wallets with native sBTC support —
no browser extension, no desktop required.

### 💵 USDCx _(Best Use of USDCx bounty)_

Send and receive USDCx (USDC bridged to Stacks). Spend in dollars,
settle on Bitcoin security. Full SIP-010 `transfer` contract call built
natively — no stacks.js.

### 🏦 USDCx Savings Goals _(Best Use of USDCx bounty)_

A native savings vault powered by a Clarity 2 smart contract deployed on
Stacks. Users create named goals with a target amount, deposit USDCx
incrementally, and withdraw at any time — no lockups, no penalties.

- Progress bar per goal showing balance vs. target
- `create-goal`, `save`, and `withdraw` signed and broadcast natively in Dart
- Goal names persisted locally per user address + contract version
- Last `txId` and raw signed bytes stored per goal for auditability
- Shared contract — deployed once, all users scoped by `tx-sender`
- Ask the AI: _"Save 10 USDCx to my holiday fund"_, _"Show my savings goals"_, _"Withdraw 5 USDCx from my holiday fund"_


```clarity
;; Users can withdraw anytime — no lockup
(define-public (withdraw (name (string-ascii 50)) (amount uint))
  (let ((caller tx-sender) ...)
    (try! (as-contract (contract-call?
            'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx
            transfer amount tx-sender caller none)))
    (ok true)))
```

### 🌐 BNS Name Resolution

Send to `.btc` names instead of raw addresses. _"Send 5 STX to bob.btc"_
resolves through the Hiro BNS API automatically.

### 🔗 dApp Browser — Full Leather + Xverse + Multi-Chain

EcoNova's WebView injects provider bridges for all major ecosystems
simultaneously — open any dApp and it just works:

| Chain          | Provider                             | Compatibility                                  |
| -------------- | ------------------------------------ | ---------------------------------------------- |
| **Stacks**     | `LeatherProvider` + `StacksProvider` | Leather v8 + Xverse / hiroWallet\*             |
| **EVM**        | `window.ethereum`                    | MetaMask-compatible, EIP-1193, chain switching |
| **Solana**     | `window.solana`                      | Phantom-compatible                             |
| **Starknet**   | `window.starknet`                    | Argent X / Braavos compatible                  |
| **MultiversX** | `window.elrondWallet`                | xPortal compatible                             |
| **NEAR**       | `window.near`                        | NEAR wallet selector compatible                |

Six provider bridges injected in parallel. Most mobile wallets inject one.

**Stacks dApp browser specifics:**

Modern `LeatherProvider.request()`:
`stx_transferStx`, `stx_transferSip10Ft`, `stx_callContract`,
`stx_deployContract`, `stx_signMessage`, `stx_signStructuredMessage`,
`stx_signTransaction`, `stx_getAddresses`, `stx_getAccounts`,
`stx_getNetworks`

Legacy `hiroWallet*` path for old `@stacks/connect` / Xverse dApps —
works without modification. JWT auth response as proper ES256K-signed token
so `decodeToken()` works on the dApp side immediately.

SIP-018 structured message display — Clarity hex decoded to human-readable
tuples in the confirmation UI.

### ⚡ x402 Autonomous Payments _(Best x402 Integration bounty)_

EcoNova supports the x402 HTTP payment protocol using STX, sBTC, and USDCx.
When the AI needs to access a paywalled API, it pays autonomously —
no human intervention required.

The first mobile wallet where the AI funds itself. Features:

- Multi-version support (v0, v1, v2)
- Method-aware retry on `402` responses
- Separate `signX402Payment` for STX (token transfer payload) and
  SIP-010 tokens (contract call payload)
- EIP-3009 signing for EVM-side x402 payments

---

## 🤖 AI-First Design

EcoNova's core is a conversational AI agent that understands your intent
and executes on-chain actions autonomously:

- _"Send 10 STX to alice.btc"_
- _"Save 5 USDCx to my holiday fund"_
- _"Show my savings goals"_
- _"How much have I saved for my holiday fund?"_
- _"Withdraw all from my holiday fund"_
- _"What's my sBTC balance?"_
- _"Pay for this API"_
- _"Swap \$20 STX to USDCx"_
- _"Send \$10 USDCx to Wisdom"_ ← using saved contacts

No addresses. No gas confusion. No chain switching. No coding required.

**🎙️ Voice Recognition** — Use your voice to execute wallet actions.
_"Send 0.1 STX to alice.btc"_ works hands-free on mobile.

**👥 Saved Contacts** — Save trusted addresses with nicknames.
_"Send 20 STX to Mom"_ — no copying long addresses.

---

## 🎯 Judging Criteria Alignment

| Criterion                    | How EcoNova delivers                                                       |
| ---------------------------- | -------------------------------------------------------------------------- |
| **Innovation**               | AI that pays itself via x402 · sBTC on mobile · savings goals via Clarity  |
| **Technical Implementation** | Native Dart signing stack, zero stacks.js, RFC 6979, SHA-512/256, c32check |
| **Stacks Alignment**         | Clarity 2 contract · sBTC · USDCx · BNS · full Leather + Xverse compat     |
| **User Experience**          | Conversational interface · voice · saved contacts · progress bars          |
| **Impact Potential**         | Only mobile Stacks wallet with this feature set · 30+ chains unified       |

---

## 🚀 Full Feature List

| Feature                                              | Status |
| ---------------------------------------------------- | ------ |
| STX send / receive                                   | ✅     |
| sBTC send / receive                                  | ✅     |
| USDCx send / receive                                 | ✅     |
| USDCx savings goals (Clarity 2)                      | ✅     |
| BNS (.btc) name resolution                           | ✅     |
| x402 autonomous payments (STX / sBTC / USDCx)        | ✅     |
| dApp browser — Leather / Xverse API                  | ✅     |
| dApp browser — EVM (MetaMask-compat)                 | ✅     |
| dApp browser — Solana / Starknet / NEAR / MultiversX | ✅     |
| SIP-018 structured message signing                   | ✅     |
| Contract call + deploy from browser                  | ✅     |
| Transaction history                                  | ✅     |
| Voice recognition                                    | ✅     |
| Saved contacts                                       | ✅     |
| Portfolio overview                                   | ✅     |
| AI natural language agent                            | ✅     |
| Multi-chain (ETH, SOL, Base, TON, and 25+ more)      | ✅     |
| USDCx savings goals (Clarity 2) — create, save, view, withdraw | ✅ |

---

## 🌐 Multi-Chain Support

Stacks is the focus — but EcoNova also supports:

**EVM** — Ethereum, BNB Chain, Polygon, Avalanche, Arbitrum, Optimism, Base
and ~15 more EVM networks.

**Other L1s** — Solana, NEAR, TON, TRON, MultiversX, Cosmos IBC chains,
Polkadot, Sui, Aptos, Harmony, Stellar, Filecoin, XRP, Zilliqa, FUSE, Ronin.

> All chains. One wallet. No MetaMask switching.

---

## 🛠 Technical Highlights

- **Native Stacks signing** — RFC 6979, SHA-512/256, secp256k1 recovery,
  SIP-010 contract calls, VersionedSmartContract deploy — pure Dart, zero stacks.js
- **c32check** — Stacks address encoding/decoding ported from TypeScript
- **Clarity decoder** — hex → human-readable (tuples, uint, string-ascii,
  principals, ok/err) for confirmation UIs matching Leather/Xverse display
- **Two-phase signing** — matches `@stacks/transactions` presign hash pattern exactly
- **JWT auth response** — ES256K-signed with correct `profile.stxAddress`
  so `decodeToken()` works on the dApp side
- **Clarity 2 savings contract** — literal principal in `contract-call?`,
  `tx-sender` captured before `as-contract` for correct withdraw destination
- **x402 multi-version** — v0/v1/v2 with method-aware retry
- **EIP-3009 signing** — for EVM-side x402 payments

---

## 🛠 Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/Imdavyking/econova_wallet
   cd econova_wallet
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure your environment:

   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```

4. Run the app:

   ```bash
   flutter run
   ```

   Requires Flutter 3.24.1+ / Dart 3.5.1+

---

## 📈 Market Opportunity

| Segment                   | Opportunity                                          |
| ------------------------- | ---------------------------------------------------- |
| Crypto wallets            | \$48B market by 2030                                 |
| Stacks ecosystem          | Only mobile wallet with full Leather + Xverse compat |
| sBTC                      | First mobile wallet with native sBTC support         |
| AI-powered interfaces     | Early-stage, high-demand UX differentiator           |
| Multi-chain fragmentation | 30+ chains, one interface                            |

---

## 🤝 Contributing & Feedback

Found a bug? Open an issue. Have a feature request? Submit a PR.

---

## 🌿 Vision

Crypto has a fragmentation problem. EcoNova solves it with one sentence.

**Bitcoin security. Stacks programmability. One conversation.**
