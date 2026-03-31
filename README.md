# 🌿 EcoNova Wallet

**EcoNova** is an AI-powered multi-chain mobile wallet.
Instead of navigating complex crypto interfaces, you just talk to it —
EcoNova handles the fragmentation of multi-chain crypto through a single
natural language interface.

> Bitcoin security. Stacks programmability. One conversation.

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

## 🤖 AI-First Design

EcoNova's core is a conversational AI agent that understands your intent
and executes on-chain actions autonomously:

- _"Send 10 STX to alice.btc"_
- _"Send $10 worth of STX to Mum"_ ← fetches live price, calculates equivalent, uses saved contact
- _"Send $10 USDCx to Wisdom"_ ← using saved contacts
- _"Save 5 USDCx to my holiday fund"_
- _"Show my savings goals"_
- _"How much have I saved for my holiday fund?"_
- _"Withdraw all from my holiday fund"_
- _"What's my sBTC balance?"_
- _"Send 0.0001 BTC to tb1q..."_ ← native SegWit BTC transfer
- _"Pay for this API"_ ← autonomous x402 payment using your funds
- _"Swap $20 STX to USDCx"_ ← opens Alex Lab DEX in the dApp browser seamlessly

**No addresses. No gas confusion. No chain switching. No coding required.**

### 🎙️ Voice Recognition

Use your voice for hands-free commands on mobile.
_"Send 0.1 STX to alice.btc"_ or _"Send 20 dollars worth of STX to Mom"_ works instantly.

### 👥 Saved Contacts

Save trusted people with nicknames once — then just say their name.
No more copying long addresses or checking explorers.

---

## 🟠 Stacks — First Citizen

Everything in EcoNova is built Stacks-first. The entire Stacks signing stack
is implemented natively in Flutter/Dart with zero JavaScript dependencies —
RFC 6979 deterministic ECDSA, SHA-512/256, SIP-010 contract calls,
c32check address encoding, and BNS resolution all ported from scratch.

### 💠 STX Transfers

Send and receive STX natively. Full two-phase signing (pre-sign hash pattern
matching `@stacks/transactions` exactly), memo support, and automatic nonce
and fee fetching from the Hiro API.

### 🟡 sBTC

Hold and transfer sBTC — Bitcoin on Stacks. The AI understands
Bitcoin-denominated instructions and maps them to sBTC operations.
EcoNova is one of the first mobile wallets with native sBTC support —
no browser extension, no desktop required.

### 💵 USDCx

Send and receive USDCx (USDC bridged to Stacks). Spend in dollars,
settle on Bitcoin security. Full SIP-010 `transfer` contract call built
natively — no stacks.js.

### 🏦 USDCx Savings Goals

A native savings vault powered by a Clarity 2 smart contract deployed on
Stacks. Users create named goals with a target amount, deposit USDCx
incrementally, and withdraw at any time — no lockups, no penalties.

- Progress bar per goal showing balance vs. target
- `create-goal`, `save`, and `withdraw` signed and broadcast natively in Dart
- Goal names persisted locally per user address + contract version
- Last `txId` and raw signed bytes stored per goal for auditability
- Shared contract — deployed once, all users scoped by `tx-sender`

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

---

## ₿ Native Bitcoin

EcoNova derives both BTC address types from the same seed, matching
Leather and Xverse exactly — and both are fully functional:

| Type            | Format                | Capability                  |
| --------------- | --------------------- | --------------------------- |
| P2WPKH (SegWit) | `bc1q...` / `tb1q...` | ✅ Send + Receive           |
| P2TR (Taproot)  | `bc1p...` / `tb1p...` | ✅ Receive (Ordinals/Runes) |

- Native BTC SegWit sends — BIP141/143 manual serialization in pure Dart,
  no bitcoin library used for signing
- BIP341 tapTweak implemented in pure Dart — correct Taproot address
  derivation matching Leather/Xverse exactly
- bech32m encoding (BIP350) for Taproot — not bech32, which produces wrong
  addresses for witness v1
- `getAddresses` response matches Leather exactly — dApps that verify BTC
  identity work without modification
- Taproot address is Ordinals/Runes-compatible — users can receive
  inscriptions directly to their EcoNova wallet

---

## 🔗 dApp Browser — Full Leather + Xverse + Multi-Chain

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

---

## ⚡ x402 Autonomous Payments

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

## 🔐 Seed Security — SLIP39

EcoNova includes native SLIP39 secret splitting — the standardised,
mnemonic-word share format used by Trezor and compatible hardware wallets.
Users can back up their seed phrase by splitting it into shares — no single
share reveals anything about the original secret.

- Shares are **BIP39-style human-readable word lists** (1024-word SLIP39 dictionary)
- **K-of-N threshold** — any K shares reconstruct the secret; fewer than K reveal nothing
- Optional **passphrase** adds an additional encryption layer
- Shares from the same split share an **identifier prefix** for easy matching
- Cross-compatible with Trezor Suite, Ian Coleman's tool, and any SLIP39-compliant wallet
- QR scan and clipboard paste on each share field for fast input
- Duplicate share detection before recovery is attempted

```
Export screen:  threshold / shares count → generate → copy each share
Import screen:  paste / scan shares → optional passphrase → reconstruct
```

---

## 💀 Dead Man's Switch

A cryptographic dead man's switch that protects your seed phrase and
automatically delivers it to a trusted beneficiary if you become
unreachable — time-locked so it cannot be decrypted before your deadline.

### How it works

1. **Arm** — Set a timeout (7 days to 1 year), enter your beneficiary's
   compressed secp256k1 public key, and choose a K-of-N share configuration.
2. **Split** — The seed is split into N shares via SSS. Each share is
   individually encrypted in two layers:
   - **AES-256-GCM** under a key derived from the target `drand` round
     number — computationally locked until that round is published.
   - **ECIES (secp256k1)** to the beneficiary's public key — only their
     private key can decrypt it after the drand round is reached.
3. **Relay** — Encrypted shares are pushed to the beneficiary automatically
   over a WebSocket relay. Nothing sensitive is ever on the server.
4. **Heartbeat** — Each time you open the app and reset the timer, shares
   are re-encrypted to a new drand round and re-sent. Old shares become
   permanently unrecoverable.
5. **Trigger** — If the deadline passes without a heartbeat, the switch
   enters the triggered state. Only the beneficiary's private key can
   decrypt the ECIES outer layer to reconstruct the seed.
6. **Cancel** — Cancelling sends a signed cancel message to the relay so
   the beneficiary's app can discard the shares.

### Security properties

| Property          | Implementation                                                      |
| ----------------- | ------------------------------------------------------------------- |
| Time-lock         | `drand` verifiable randomness — deterministic, public, tamper-proof |
| Confidentiality   | ECIES secp256k1 + AES-256-GCM double encryption                     |
| Forward secrecy   | Every heartbeat rotates the drand round and re-encrypts             |
| Integrity         | HMAC-SHA256 `dataHash` binds shares to sender address + mnemonic    |
| Share threshold   | SSS K-of-N — beneficiary needs K shares to reconstruct              |
| Replay protection | Cancel message includes `dataHash`; relay deletes matching sessions |

---

## 🔒 Native Cryptography — Pure Dart

All cryptographic primitives are implemented from scratch in pure Dart with
no native bindings or platform channels. The same code runs identically on
Android, iOS, macOS, and in tests.

| Primitive                   | Usage                                           |
| --------------------------- | ----------------------------------------------- |
| **ECIES secp256k1**         | Dead man's switch share encryption / decryption |
| **AES-256-GCM**             | Symmetric encryption with authenticated data    |
| **HMAC-SHA256**             | Data integrity hashes and HKDF key derivation   |
| **HKDF-SHA256**             | ECIES shared-secret → AES key expansion         |
| **SSS (GF-256)**            | Shamir secret splitting for dead man's switch   |
| **SLIP39**                  | BIP39-style mnemonic share encoding / decoding  |
| **RS1024 checksum**         | SLIP39 mnemonic integrity validation            |
| **Feistel cipher (PBKDF2)** | SLIP39 master secret encryption / decryption    |

Every primitive has a corresponding round-trip test — wrong keys, tampered
ciphertext, and truncated shares all throw before any result reaches the UI.

---

## 🗝️ Wallet Import Formats

EcoNova accepts three import formats, all normalised to the same internal
`SeedPhraseRoot` representation at import time:

| Format             | Example                  | Notes                                                  |
| ------------------ | ------------------------ | ------------------------------------------------------ |
| **BIP39 mnemonic** | `abandon ability able …` | 12 or 24 words; validated via `bip39.validateMnemonic` |
| **BIP32 seed hex** | `7e9f86e818b5b8…`        | 64-byte raw seed, `0x` prefix optional                 |
| **EIP-3 keystore** | `{"version":3, …}`       | PBKDF2 or scrypt; decrypts to private key              |

```dart
Future<SeedPhraseRoot> seedFromMnemonic(String phraseOrBipSeedHex) async {
  final isValid = await compute(bip39.validateMnemonic, phraseOrBipSeedHex);
  final seed = isValid
      ? bip39.mnemonicToSeed(phraseOrBipSeedHex)          // BIP39 → 64 bytes
      : HEX.decode(strip0x(phraseOrBipSeedHex));          // raw hex seed
  return SeedPhraseRoot(seed, bip32.BIP32.fromSeed(seed));
}
```

---

## 🌐 Multi-Chain Support

Stacks is the focus — but EcoNova also supports:

**Bitcoin** — Native P2WPKH SegWit send/receive and P2TR Taproot receive,
both derived from the same seed as Leather and Xverse.

**EVM** — Ethereum, BNB Chain, Polygon, Avalanche, Arbitrum, Optimism, Base
and ~15 more EVM networks.

**Other L1s** — Solana, NEAR, TON, TRON, MultiversX, Cosmos IBC chains,
Polkadot, Sui, Aptos, Harmony, Stellar, Filecoin, XRP, Zilliqa, FUSE, Ronin.

> All chains. One wallet. No MetaMask switching.

---

## 🚀 Full Feature List

| Feature                                                             | Status |
| ------------------------------------------------------------------- | ------ |
| STX send / receive                                                  | ✅     |
| sBTC send / receive                                                 | ✅     |
| USDCx send / receive                                                | ✅     |
| USDCx savings goals (Clarity 2) — create, save, view, withdraw      | ✅     |
| BNS (.btc) name resolution                                          | ✅     |
| x402 autonomous payments (STX / sBTC / USDCx)                       | ✅     |
| Native BTC SegWit send / receive (P2WPKH, BIP143)                   | ✅     |
| Native BTC Taproot receive — Ordinals / Runes (P2TR, BIP341)        | ✅     |
| dApp browser — Leather / Xverse API                                 | ✅     |
| dApp browser — EVM (MetaMask-compat)                                | ✅     |
| dApp browser — Solana / Starknet / NEAR / MultiversX                | ✅     |
| SIP-018 structured message signing                                  | ✅     |
| Contract call + deploy from browser                                 | ✅     |
| Transaction history                                                 | ✅     |
| Voice recognition                                                   | ✅     |
| Saved contacts                                                      | ✅     |
| Portfolio overview                                                  | ✅     |
| AI natural language agent                                           | ✅     |
| Multi-chain (ETH, SOL, Base, TON, and 25+ more)                     | ✅     |
| SLIP39 — BIP39-style mnemonic shares, passphrase, Trezor-compatible | ✅     |
| Dead man's switch — drand time-lock + ECIES + relay auto-delivery   | ✅     |
| ECIES secp256k1 encryption / decryption (pure Dart)                 | ✅     |
| AES-256-GCM encryption / decryption (pure Dart)                     | ✅     |
| EIP-3 keystore import (PBKDF2 / scrypt)                             | ✅     |
| BIP39 mnemonic + raw BIP32 hex seed import                          | ✅     |

---

## 🛠 Technical Highlights

- **Native Stacks signing** — RFC 6979, SHA-512/256, secp256k1 recovery,
  SIP-010 contract calls, VersionedSmartContract deploy — pure Dart, zero stacks.js
- **c32check** — Stacks address encoding/decoding ported from TypeScript
- **Clarity decoder** — hex → human-readable (tuples, uint, string-ascii,
  principals, ok/err) for confirmation UIs matching Leather/Xverse display
- **Two-phase signing** — matches `@stacks/transactions` presign hash pattern exactly
- **JWT auth response** — ES256K-signed with correct `profile.stxAddress`
  and BTC addresses so `decodeToken()` works on the dApp side
- **Clarity 2 savings contract** — literal principal in `contract-call?`,
  `tx-sender` captured before `as-contract` for correct withdraw destination
- **x402 multi-version** — v0/v1/v2 with method-aware retry
- **EIP-3009 signing** — for EVM-side x402 payments
- **Native BTC SegWit signing** — BIP141/143 manual transaction serialization
  in pure Dart — UTXO selection, sighash preimage, DER signature encoding,
  witness construction — no bitcoin library used for signing
- **BIP341 tapTweak** — secp256k1 point arithmetic in pure Dart for correct
  Taproot address derivation
- **bech32m (BIP350)** — self-contained encoder for witness v1 (Taproot),
  distinct from bech32 (BIP173) used for witness v0 (SegWit)
- **Leather-compatible `getAddresses`** — P2WPKH + P2TR + STX returned with
  correct public keys, tweaked keys, and derivation paths matching Leather exactly
- **SLIP39** — full implementation: RS1024 checksum, Feistel cipher, PBKDF2
  passphrase stretching, 1024-word dictionary — cross-compatible with Trezor Suite
- **ECIES secp256k1** — ephemeral key agreement + HKDF-SHA256 + AES-256-GCM
- **Dead man's switch** — drand verifiable randomness, double-encrypted shares,
  WebSocket relay with HMAC-bound session integrity, heartbeat-based forward secrecy
- **EIP-3 keystore import** — PBKDF2-HMAC-SHA256, AES-128-CTR, MAC verification
- **Flexible seed import** — BIP39 mnemonic or raw BIP32 hex, both normalised
  to the same `SeedPhraseRoot`

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

   ```bash
   cp .env.example .env
   ```

   Open `.env` and fill in your API keys.
   Each key is commented with a link to where you can get it for free.
   See [`.env.example`](.env.example) for the full list.

4. Run the app:

   ```bash
   flutter run
   ```

   Requires Flutter 3.24.1+ / Dart 3.5.1+

---

## 🔐 Secrets Management

API keys are stored encrypted in Bitwarden. Never commit `.env` to version control.

```bash
echo ".env" >> .gitignore
```

### Setup (one-time)

Install the Bitwarden CLI and add an unlock alias to your shell config:

```bash
npm install -g @bitwarden/cli

# Add to ~/.zshrc
bwu() {
  export BW_SESSION="$(bw unlock --raw)"
}
```

### Upload

```bash
bwu  # unlock vault

bw get template item > item.json
jq --arg notes "$(cat .env)" \
  '.type = 2 | .name = "econova .env" | .notes = $notes | .secureNote = {"type": 0}' \
  item.json > filled.json
bw encode < filled.json | bw create item
rm item.json filled.json
```

### Retrieve

```bash
bwu  # unlock vault
bw get notes "econova .env" > .env
```

---

## 📈 Market Opportunity

| Segment                    | Opportunity                                                 |
| -------------------------- | ----------------------------------------------------------- |
| Crypto wallets             | \$48B market by 2030                                        |
| Stacks ecosystem           | Only mobile wallet with full Leather + Xverse compat        |
| sBTC                       | First mobile wallet with native sBTC support                |
| Bitcoin (SegWit + Taproot) | Native send/receive — no library, pure Dart signing         |
| AI-powered interfaces      | Early-stage, high-demand UX differentiator                  |
| Multi-chain fragmentation  | 30+ chains, one interface                                   |
| Seed security              | Only mobile wallet with SLIP39 + dead man's switch built-in |

---

## 🤝 Contributing & Feedback

Found a bug? Open an issue. Have a feature request? Submit a PR.

---

## 🌿 Vision

Crypto has a fragmentation problem. EcoNova solves it with one sentence.

**Bitcoin security. Stacks programmability. One conversation.**
