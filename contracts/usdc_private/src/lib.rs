#![no_std]

mod field;
mod incremental_merkle_tree;
mod poseidon2lib;
mod u512;

mod verifier {
    use soroban_sdk::{contractclient, contracterror, Bytes, Env};

    #[contracterror]
    #[repr(u32)]
    #[derive(Copy, Clone, Debug, Eq, PartialEq)]
    pub enum VerifierError {
        VkParseError = 1,
        ProofParseError = 2,
        VerificationFailed = 3,
        VkNotSet = 4,
    }

    #[contractclient(name = "UltraHonkVerifierClient")]
    pub trait UltraHonkVerifierTrait {
        fn verify_proof(
            env: Env,
            public_inputs: Bytes,
            proof_bytes: Bytes,
        ) -> Result<(), VerifierError>;
    }
}

use field::field_zero;
use incremental_merkle_tree::IncrementalMerkleTree;
use poseidon2lib::Poseidon2;
use soroban_sdk::{
    contract, contracterror, contractimpl, contracttype, panic_with_error, symbol_short,
    token::StellarAssetClient, xdr::ToXdr, Address, Bytes, Env, Symbol, Vec, U256,
};

// ── Constants ─────────────────────────────────────────────────────────────────

/// Fixed deposit denomination — 1 USDC (7 decimals = 10_000_000 stroops).
const DEPOSIT_AMOUNT: i128 = 10_000_000;

const TREE_DEPTH: u32 = 8;
const USDC_SAC: &str = "CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA";

// ── Errors ────────────────────────────────────────────────────────────────────

#[contracterror]
#[derive(Copy, Clone, Debug, PartialEq)]
#[repr(u32)]
pub enum Error {
    NotInitialized = 1,
    AlreadyInitialized = 2,
    InvalidProof = 3,
    UnknownRoot = 4,
    NullifierUsed = 5,
    CommitmentUsed = 6,
    NotIntendedRecipient = 7,
    NotOwner = 8,
    ZeroAddress = 9,
}

// ── Storage keys ──────────────────────────────────────────────────────────────

#[contracttype]
#[derive(Clone)]
pub enum DataKey {
    Owner,
    Verifier,
    /// SAC contract address (C…) for the classic asset (e.g. USDC).
    AssetContract,
    MerkleTree,
    NullifierUsed(U256),
    CommitmentUsed(U256),
    DepositLog,
}

// ── Storage types ─────────────────────────────────────────────────────────────

#[contracttype]
#[derive(Clone)]
pub struct DepositEntry {
    pub commitment: U256,
    pub leaf_index: u32,
}

// ── Events ────────────────────────────────────────────────────────────────────

#[contracttype]
#[derive(Clone)]
pub struct DepositEvent {
    pub commitment: U256,
    pub leaf_index: u32,
    pub timestamp: u64,
}

#[contracttype]
#[derive(Clone)]
pub struct WithdrawalEvent {
    pub recipient: Address,
    pub nullifier_hash: U256,
}

#[contracttype]
#[derive(Clone)]
pub struct OwnershipTransferredEvent {
    pub previous_owner: Address,
    pub new_owner: Address,
}

// ── Internal helpers ──────────────────────────────────────────────────────────

fn field_modulus(env: &Env) -> U256 {
    U256::from_parts(
        env,
        0x30644e72e131a029_u64,
        0xb85045b68181585d_u64,
        0x2833e84879b97091_u64,
        0x43e1f593f0000001_u64,
    )
}

fn address_to_field(env: &Env, pub_key_bytes: Bytes) -> U256 {
    let n = U256::from_be_bytes(env, &pub_key_bytes);
    n.rem_euclid(&field_modulus(env))
}

fn signal_u256(env: &Env, public_inputs: &Bytes, index: u32) -> U256 {
    let slice = public_inputs.slice((index * 32)..((index + 1) * 32));
    U256::from_be_bytes(env, &slice)
}

fn load_tree(env: &Env) -> IncrementalMerkleTree {
    env.storage()
        .instance()
        .get(&DataKey::MerkleTree)
        .unwrap_or_else(|| panic_with_error!(env, Error::NotInitialized))
}

fn save_tree(env: &Env, tree: &IncrementalMerkleTree) {
    env.storage().instance().set(&DataKey::MerkleTree, tree);
}

fn asset_client(env: &Env) -> StellarAssetClient {
    let addr: Address = env
        .storage()
        .instance()
        .get(&DataKey::AssetContract)
        .unwrap_or_else(|| panic_with_error!(env, Error::NotInitialized));
    StellarAssetClient::new(env, &addr)
}

fn only_owner(env: &Env, caller: &Address) {
    let owner: Address = env
        .storage()
        .instance()
        .get(&DataKey::Owner)
        .unwrap_or_else(|| panic_with_error!(env, Error::NotInitialized));
    if owner != *caller {
        panic_with_error!(env, Error::NotOwner);
    }
}

fn verify_proof_and_consume(
    env: &Env,
    recipient: &Address,
    proof_bytes: &Bytes,
    public_inputs: &Bytes,
) -> U256 {
    let verifier_addr: Address = env
        .storage()
        .instance()
        .get(&DataKey::Verifier)
        .unwrap_or_else(|| panic_with_error!(env, Error::NotInitialized));

    let verifier = verifier::UltraHonkVerifierClient::new(env, &verifier_addr);
    verifier.verify_proof(public_inputs, proof_bytes);

    let root = signal_u256(env, public_inputs, 0);
    let nullifier_hash = signal_u256(env, public_inputs, 1);
    let recipient_hash = signal_u256(env, public_inputs, 2);

    // Verify recipient commitment in proof matches actual recipient
    let xdr_bytes = recipient.clone().to_xdr(env);
    let raw_pub_key = xdr_bytes.slice(12..44);
    let field_val = address_to_field(env, raw_pub_key);
    if Poseidon2::hash_1(env, field_val) != recipient_hash {
        panic_with_error!(env, Error::NotIntendedRecipient);
    }

    // Root must be a known historical root
    let tree = load_tree(env);
    if !tree.is_known_root(env, root) {
        panic_with_error!(env, Error::UnknownRoot);
    }

    // Nullifier must not have been spent
    if env
        .storage()
        .instance()
        .get::<DataKey, bool>(&DataKey::NullifierUsed(nullifier_hash.clone()))
        .unwrap_or(false)
    {
        panic_with_error!(env, Error::NullifierUsed);
    }
    env.storage()
        .instance()
        .set(&DataKey::NullifierUsed(nullifier_hash.clone()), &true);

    nullifier_hash
}

// ── Contract ──────────────────────────────────────────────────────────────────

#[contract]
pub struct PrivateVault;

#[contractimpl]
impl PrivateVault {
    /// `asset_contract` — SAC `C…` address for the classic asset.
    ///
    /// Derive before deploying:
    /// ```
    /// stellar contract id asset \
    ///   --asset USDC:GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5 \
    ///   --network testnet --source YOUR_KEY
    /// ```
    /// CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA
    pub fn __constructor(env: Env,verifier: Address) {
        let usdc_addr = Address::from_str(&env, USDC_SAC);
        env.storage().instance().set(&DataKey::Verifier, &verifier);
        env.storage()
            .instance()
            .set(&DataKey::AssetContract, &usdc_addr);
        let tree = IncrementalMerkleTree::initializer(&env, TREE_DEPTH);
        save_tree(&env, &tree);
    }

    // ── DEPOSIT ───────────────────────────────────────────────────────────────

    /// Deposit a fixed note of `DEPOSIT_AMOUNT` classic USDC.
    ///
    /// Before calling this, user must approve the SAC:
    ///   `SAC.approve(caller, vault_address, DEPOSIT_AMOUNT, live_until_ledger)`
    ///
    /// `commitment` — Poseidon2(secret, nullifier) computed client-side.
    pub fn deposit(env: Env, caller: Address, commitment: U256) {
        caller.require_auth();

        if env
            .storage()
            .instance()
            .get::<DataKey, bool>(&DataKey::CommitmentUsed(commitment.clone()))
            .unwrap_or(false)
        {
            panic_with_error!(&env, Error::CommitmentUsed);
        }

        // Pull DEPOSIT_AMOUNT from caller via SAC transfer_from.
        // StellarAssetClient bridges classic G… assets into Soroban transparently.
        asset_client(&env).transfer_from(
            &env.current_contract_address(), // spender (this contract)
            &caller,                         // from    (user)
            &env.current_contract_address(), // to      (this contract)
            &DEPOSIT_AMOUNT,
        );

        // Insert commitment into incremental Merkle tree
        let mut tree = load_tree(&env);
        let leaf_index = tree.insert(&env, commitment.clone());
        save_tree(&env, &tree);

        env.storage()
            .instance()
            .set(&DataKey::CommitmentUsed(commitment.clone()), &true);

        // Append to deposit log for on-chain view queries
        let mut log: Vec<DepositEntry> = env
            .storage()
            .instance()
            .get(&DataKey::DepositLog)
            .unwrap_or_else(|| Vec::new(&env));
        log.push_back(DepositEntry {
            commitment: commitment.clone(),
            leaf_index,
        });
        env.storage().instance().set(&DataKey::DepositLog, &log);

        env.events().publish(
            (symbol_short!("deposit"), commitment.clone()),
            DepositEvent {
                commitment,
                leaf_index,
                timestamp: env.ledger().timestamp(),
            },
        );
    }

    // ── ZK WITHDRAW ───────────────────────────────────────────────────────────

    /// Withdraw a fixed note of `DEPOSIT_AMOUNT` to `recipient`.
    ///
    /// Inputs:
    ///   - `proof_bytes`   — UltraHonk proof bytes
    ///   - `public_inputs` — [root (32B) | nullifier_hash (32B) | recipient_hash (32B)]
    ///
    /// No link between depositor and recipient is revealed on-chain.
    pub fn zk_withdraw(env: Env, recipient: Address, proof_bytes: Bytes, public_inputs: Bytes) {
        let nullifier_hash =
            verify_proof_and_consume(&env, &recipient, &proof_bytes, &public_inputs);

        // Push DEPOSIT_AMOUNT from vault → recipient via SAC transfer
        asset_client(&env).transfer(&env.current_contract_address(), &recipient, &DEPOSIT_AMOUNT);

        env.events().publish(
            (Symbol::new(&env, "withdrawal"), nullifier_hash.clone()),
            WithdrawalEvent {
                recipient,
                nullifier_hash,
            },
        );
    }

    // ── Debug ─────────────────────────────────────────────────────────────────

    pub fn debug_recipient_field(env: Env, recipient: Address) -> (U256, U256, u32) {
        let xdr_bytes = recipient.clone().to_xdr(&env);
        let xdr_len = xdr_bytes.len();
        let raw_pub_key = xdr_bytes.slice(12..44);
        let field_val = address_to_field(&env, raw_pub_key);
        let hash = Poseidon2::hash_1(&env, field_val.clone());
        (field_val, hash, xdr_len)
    }

    // ── Views ─────────────────────────────────────────────────────────────────

    pub fn current_root(env: Env) -> U256 {
        load_tree(&env).current_root(&env)
    }

    pub fn next_leaf_index(env: Env) -> u32 {
        load_tree(&env).next_leaf_index()
    }

    pub fn is_known_root(env: Env, root: U256) -> bool {
        load_tree(&env).is_known_root(&env, root)
    }

    pub fn get_all_deposits(env: Env) -> Vec<DepositEntry> {
        env.storage()
            .instance()
            .get(&DataKey::DepositLog)
            .unwrap_or_else(|| Vec::new(&env))
    }

    pub fn asset_contract(env: Env) -> Address {
        env.storage()
            .instance()
            .get(&DataKey::AssetContract)
            .unwrap_or_else(|| panic_with_error!(&env, Error::NotInitialized))
    }

    pub fn verifier_address(env: Env) -> Address {
        env.storage()
            .instance()
            .get(&DataKey::Verifier)
            .unwrap_or_else(|| panic_with_error!(&env, Error::NotInitialized))
    }


    pub fn deposit_amount(_env: Env) -> i128 {
        DEPOSIT_AMOUNT
    }

    // ── Admin ─────────────────────────────────────────────────────────────────

    pub fn set_verifier(env: Env, caller: Address, verifier: Address) {
        caller.require_auth();
        only_owner(&env, &caller);
        env.storage().instance().set(&DataKey::Verifier, &verifier);
    }

    pub fn transfer_ownership(env: Env, caller: Address, new_owner: Address) {
        caller.require_auth();
        only_owner(&env, &caller);
        let previous_owner = caller;
        env.storage().instance().set(&DataKey::Owner, &new_owner);
        env.events().publish(
            (Symbol::new(&env, "ownership_transferred"),),
            OwnershipTransferredEvent {
                previous_owner,
                new_owner,
            },
        );
    }

    /// Emergency drain — owner recovers stuck funds.
    pub fn admin_withdraw(env: Env, caller: Address, recipient: Address, amount: i128) {
        caller.require_auth();
        only_owner(&env, &caller);
        asset_client(&env).transfer(&env.current_contract_address(), &recipient, &amount);
    }
}

// tellar contract id asset \
//   --asset USDC:GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5 \
//   --network testnet
// ⚠️  A new release of Stellar CLI is available:
