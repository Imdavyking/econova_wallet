# Econova

**Next‑Generation Privacy-first Mobile Wallet & Self‑Custody SDK**

**Tagline:** _Private by design. Portable by default._

---

<table><thead><tr><th width="125.3046875">Network</th><th>USDCx token contract</th><th>USDC xReserve protocol (entrypoint)</th></tr></thead><tbody><tr><td>Mainnet</td><td><a href="https://explorer.hiro.so/txid/0x07ea0a8d7262acd0cb094006969527351883281e08ebb6535843c5dbbde31ce9?chain=mainnet">SP120SBRBQJ00MCWS7TM5R8WJNTTKD5K0HFRC2CNE.usdcx</a></td><td><a href="https://explorer.hiro.so/txid/0xb5f29114ecdbaf199887433cdd4ca46d177d60875141e1dfb67304b53bf2df11?chain=mainnet">SP120SBRBQJ00MCWS7TM5R8WJNTTKD5K0HFRC2CNE.usdcx-v1</a></td></tr><tr><td>Testnet</td><td><a href="https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx?chain=testnet">ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx</a></td><td><a href="https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx-v1?chain=testnet">ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx-v1</a></td></tr></tbody></table>

## Overview

Econova is a next‑generation self‑custody wallet and mobile SDK focused on privacy, discreet UX, and powerful tooling for managing private assets across chains. Built for developers and end users, Econova blends advanced on‑device key management, wallet‑hiding workflows, and privacy‑preserving features to minimize surface area for tracking and abuse while maintaining a smooth UX.

Econova is ideal for teams building wallets, dApps with embedded custody, or privacy-first financial experiences. Submissions implementing Econova for the Osmosis bounty should highlight self‑custody innovations and wallet privacy options.

---

## Key features

- **Mobile-first SDKs** (iOS / Android / React Native / Flutter) for quick wallet integration.
- **On‑device secure key storage** using platform keystores + optional E2EE encrypted backups.
- **Wallet Hiding / Camouflage Mode**: discretely hide wallet UI, obfuscate app icon, stealth access gestures, and decoy modes.
- **Privacy‑first UX patterns**: ephemeral QR codes, burner wallet creation, and minimal telemetry.
- **Account abstraction support**: plug in social recovery or smart‑account flows while preserving self‑custody guarantees.
- **Transaction privacy options**: batched broadcasts, relay routing, and optional coin‑control privacy primitives.
- **Cross‑chain asset management** with modular adapters (EVM, Cosmos/IBC, Sui, Solana experimental).
- **Plug‑in MCP / AI context adapters** (for private on‑device assistants) — optional, privacy constrained.
- **Auditable security**: deterministic key derivation, secure signing flows, and easy audit hooks.

---

## Architecture (high level)

1. **Econova SDK (mobile)**

   - Key management layer (KML): handles generation, storage (keystore/secure enclave), derivation, and signing.
   - Privacy middleware: implements hiding, decoys, ephemeral sessions, and telemetry controls.
   - Network adapters: modular adapters for RPC, relayers, and IBC/bridge connectors.

2. **Econova Core (server, optional)**

   - Backup & recovery relay (E2EE): stores encrypted blobs with zero‑knowledge attestation of integrity.
   - Push relayer (opt‑in): broadcast helper for poor‑connectivity devices.

3. **dApp Integration Layer**

   - Web and mobile connectors (WalletConnect+, custom Mobile SDK APIs).

---

## Wallet Hiding & Privacy Modes

Econova provides multiple privacy modes a user can enable depending on threat model:

### 1. Camouflage App Mode

- Replace app icon and name with a neutral utility (settings, notes) — reversible by PIN/gesture.
- Optional stealth entry: double‑tap pattern or long‑press the notification to unlock wallet UI.

### 2. Decoy Wallets

- Create one or more decoy wallets with fake balances and dummy transaction history.
- Primary wallet accessible only via hidden gesture or passphrase.

### 3. Burners & Ephemeral Sessions

- Create ephemeral short‑lived wallets for on‑the‑fly micro‑transactions.
- Ephemeral private keys not backed up — perfect for single‑use activities.

### 4. Minimal Telemetry & Offline Mode

- Default telemetry: **off**. All analytics are opt‑in and strictly differential/private.
- Offline signing with QR handshake and manual transaction broadcasting.

---

## Security model

- Keys are never exported in plaintext. Use platform secure enclaves (Secure Enclave, Keystore) + optional software fallback with PBKDF2/Argon2 and E2EE backup.
- All backup blobs are end‑to‑end encrypted; encryption keys are derived from user secrets (seed/pin + optional MFA device).
- Signing UX verifies the purpose, destination, and amount in two steps (compact view + full view) to prevent UX attacks.
- Support for hardware wallet integration (via BLE / USB) for high‑value accounts.

---
