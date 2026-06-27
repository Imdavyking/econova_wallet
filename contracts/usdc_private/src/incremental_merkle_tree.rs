#![no_std]

use soroban_sdk::{contracttype, Env, U256};

use crate::field::{
    field_add, field_is_zero, field_new, field_new_unchecked, field_signed, field_zero,
};
use crate::poseidon2lib::Poseidon2;

// -------------------------------------------------------
// Constants
// -------------------------------------------------------

const ROOT_HISTORY_SIZE: u32 = 30;

// -------------------------------------------------------
// Errors
// -------------------------------------------------------

pub mod Errors {
    pub const DEPTH_ZERO: &str = "depth must be > 0";
    pub const DEPTH_TOO_LARGE: &str = "depth must be < 32";
    pub const INDEX_OUT_OF_BOUNDS: &str = "index out of bounds";
    pub const TREE_FULL: &str = "merkle tree is full";
}

// -------------------------------------------------------
// Storage
// -------------------------------------------------------

#[contracttype]
pub struct IncrementalMerkleTree {
    pub depth: u32,
    pub roots: soroban_sdk::Map<u32, U256>, // circular buffer of last 30 roots
    pub current_root_index: u32,
    pub next_leaf_index: u32,
    pub cached_subtrees: soroban_sdk::Map<u32, U256>, // cached left siblings per level
}

// -------------------------------------------------------
// Helper functions (precomputed zeros + pow2)
// -------------------------------------------------------

// Precomputed Poseidon2 zero subtrees for BN254 (matches Cairo/Solidity exactly)
fn zeros(env: &Env, i: u32) -> U256 {
    match i {
        0 => U256::from_parts(
            env,
            0x0d823319708ab99e,
            0xc915efd4f7e03d11,
            0xca1790918e8f04cd,
            0x14100aceca2aa9ff,
        ),
        1 => U256::from_parts(
            env,
            0x170a9598425eb05e,
            0xb8dc06986c6afc71,
            0x7811e874326a7957,
            0x6c02d338bdf14f13,
        ),
        2 => U256::from_parts(
            env,
            0x273b1a40397b618d,
            0xac2fc66ceb71399a,
            0x3e1a60341e546e05,
            0x3cbfa5995e824caf,
        ),
        3 => U256::from_parts(
            env,
            0x16bf9b1fb2dfa9d8,
            0x8cfb1752d6937a15,
            0x94d257c2053dff3c,
            0xb971016bfcffe2a1,
        ),
        4 => U256::from_parts(
            env,
            0x1288271e1f93a29f,
            0xa6e748b7468a77a9,
            0xb8fc3db6b216ce5f,
            0xc2601fc3e9bd6b36,
        ),
        5 => U256::from_parts(
            env,
            0x1d47548adec10683,
            0x54d163be4ffa348c,
            0xa89f079b039c9191,
            0x378584abd79edeca,
        ),
        6 => U256::from_parts(
            env,
            0x0b98a89e6827ef69,
            0x7b8fb2e280a2342d,
            0x61db1eb5efc229f5,
            0xf4a77fb333b80bef,
        ),
        7 => U256::from_parts(
            env,
            0x231555e37e6b206f,
            0x43fdcd4d660c4744,
            0x2d76aab1ef552aef,
            0x6db45f3f9cf2e955,
        ),
        8 => U256::from_parts(
            env,
            0x03d0dc8c92e2844a,
            0xbcc5fdefe8cb67d9,
            0x3034de0862943990,
            0xb09c6b8e3fa27a86,
        ),
        9 => U256::from_parts(
            env,
            0x1d51ac275f47f10e,
            0x592b8e690fd3b28a,
            0x76106893ac3e60cd,
            0x7b2a3a443f4e8355,
        ),
        10 => U256::from_parts(
            env,
            0x16b671eb844a8e4e,
            0x463e820e26560357,
            0xedee4ecfdbf5d7b0,
            0xa28799911505088d,
        ),
        11 => U256::from_parts(
            env,
            0x115ea0c2f132c591,
            0x4d5bb737af6eed04,
            0x115a3896f0d65e12,
            0xe761ca560083da15,
        ),
        12 => U256::from_parts(
            env,
            0x139a5b42099806c7,
            0x6efb52da0ec1dde0,
            0x6a836bf6f87ef7ab,
            0x4bac7d00637e28f0,
        ),
        13 => U256::from_parts(
            env,
            0x0804853482335a65,
            0x33eb6a4ddfc215a0,
            0x8026db413d247a76,
            0x95e807e38debea8e,
        ),
        14 => U256::from_parts(
            env,
            0x2f0b264ab5f5630b,
            0x591af93d93ec2dfe,
            0xd28eef017b251e40,
            0x905cdf7983689803,
        ),
        15 => U256::from_parts(
            env,
            0x170fc161bf1b9610,
            0xbf196c173bdae82c,
            0x4adfd93888dc317f,
            0x5010822a3ba9ebee,
        ),
        16 => U256::from_parts(
            env,
            0x0b2e7665b17622cc,
            0x0243b6fa35110aa7,
            0xdd0ee3cc94096501,
            0x72aa786ca5971439,
        ),
        17 => U256::from_parts(
            env,
            0x12d5a033cbeff854,
            0xc5ba0c5628ac4628,
            0x104be6ab370699a1,
            0xb2b4209e518b0ac5,
        ),
        18 => U256::from_parts(
            env,
            0x1bc59846eb7eafaf,
            0xc85ba9a99a895627,
            0x63735322e4255b7c,
            0x1788a8fe8b90bf5d,
        ),
        19 => U256::from_parts(
            env,
            0x1b9421fbd79f6972,
            0xa348a3dd4721781e,
            0xc25a5d8d27342942,
            0xae00aba80a3904d4,
        ),
        20 => U256::from_parts(
            env,
            0x087fde1c4c9c27c3,
            0x47f347083139eee8,
            0x759179d255ec8381,
            0xc02298d3d6ccd233,
        ),
        21 => U256::from_parts(
            env,
            0x1e26b1884cb500b5,
            0xe6bbfdeedbdca34b,
            0x961caf3fa9839ea7,
            0x94bfc7f87d10b3f1,
        ),
        22 => U256::from_parts(
            env,
            0x09fc1a538b88bda5,
            0x5a53253c62c153e6,
            0x7e8289729afd9b8b,
            0xfd3f46f5eecd5a72,
        ),
        23 => U256::from_parts(
            env,
            0x14cd0edec3423652,
            0x211db5210475a230,
            0xca4771cd1e45315b,
            0xcd6ea640f14077e2,
        ),
        24 => U256::from_parts(
            env,
            0x1d776a76bc76f430,
            0x5ef0b0b27a58a956,
            0x5864fe1b9f2a198e,
            0x8247b3e599e036ca,
        ),
        25 => U256::from_parts(
            env,
            0x1f93e3103fed2d3b,
            0xd056c3ac49b4a072,
            0x8578be3359595978,
            0x8fa25514cdb5d42f,
        ),
        26 => U256::from_parts(
            env,
            0x138b0576ee7346fb,
            0x3f6cfb632f92ae20,
            0x6395824b9333a183,
            0xc15470404c977a3b,
        ),
        27 => U256::from_parts(
            env,
            0x0745de8522abfcd2,
            0x4bd50875865592f7,
            0x3a190070b4cb3d89,
            0x76e3dbff8fdb7f3d,
        ),
        28 => U256::from_parts(
            env,
            0x2ffb8c798b9dd264,
            0x5e9187858cb92a86,
            0xc86dcd1138f5d610,
            0xc33df2696f5f6860,
        ),
        29 => U256::from_parts(
            env,
            0x2612a1395168260c,
            0x9999287df0e3c3f1,
            0xb0d8e008e90cd159,
            0x41e4c2df08a68a5a,
        ),
        30 => U256::from_parts(
            env,
            0x10ebedce66a91003,
            0x9c8edb2cd832d6a9,
            0x857648ccff5e99b5,
            0xd08009b44b088edf,
        ),
        31 => U256::from_parts(
            env,
            0x213fb841f9de0695,
            0x8cf4403477bdbff7,
            0xc59d6249daabfee1,
            0x47f853db7c808082,
        ),
        _ => panic!("depth out of bounds"),
    }
}

fn pow2(n: u32) -> u32 {
    let mut result = 1u32;
    let mut i = 0u32;
    while i < n {
        result *= 2;
        i += 1;
    }
    result
}

// -------------------------------------------------------
// Main Implementation
// -------------------------------------------------------

impl IncrementalMerkleTree {
    // Initialize (call from contract constructor)
    pub fn initializer(env: &Env, depth: u32) -> Self {
        assert!(depth > 0, "{}", Errors::DEPTH_ZERO);
        assert!(depth < 32, "{}", Errors::DEPTH_TOO_LARGE);

        let mut roots = soroban_sdk::Map::new(env);
        roots.set(0, zeros(env, depth)); // initial all-zero root

        Self {
            depth,
            roots,
            current_root_index: 0,
            next_leaf_index: 0,
            cached_subtrees: soroban_sdk::Map::new(env),
        }
    }

    // Insert a leaf, returns the inserted leaf index
    pub fn insert(&mut self, env: &Env, leaf: U256) -> u32 {
        let next_index = self.next_leaf_index;
        let depth = self.depth;

        assert!(next_index < pow2(depth), "{}", Errors::TREE_FULL);

        let mut current_index = next_index;
        let mut current_hash = field_new(env, leaf);

        let mut i: u32 = 0;
        while i < depth {
            let (left, right) = if current_index % 2 == 0 {
                // even → left child, right sibling is zero subtree
                self.cached_subtrees.set(i, current_hash.clone());
                (current_hash.clone(), zeros(env, i))
            } else {
                // odd → right child, left sibling from cache
                let left = self
                    .cached_subtrees
                    .get(i)
                    .unwrap_or_else(|| field_zero(env));
                (left, current_hash.clone())
            };

            current_hash = Poseidon2::hash_2(env, left, right);
            current_index /= 2;
            i += 1;
        }

        // Store new root in circular buffer
        let new_root_index = (self.current_root_index + 1) % ROOT_HISTORY_SIZE;
        self.current_root_index = new_root_index;
        self.roots.set(new_root_index, current_hash.clone());

        self.next_leaf_index += 1;

        next_index
    }

    // Check if a root was seen in the last ROOT_HISTORY_SIZE roots
    pub fn is_known_root(&self, env: &Env, root: U256) -> bool {
        if field_is_zero(env, &root) {
            return false;
        }

        let current = self.current_root_index;
        let mut i = current;

        loop {
            if let Some(stored) = self.roots.get(i) {
                if stored == root {
                    return true;
                }
            }

            i = if i == 0 { ROOT_HISTORY_SIZE - 1 } else { i - 1 };

            if i == current {
                break false;
            }
        }
    }

    pub fn current_root(&self, env: &Env) -> U256 {
        self.roots
            .get(self.current_root_index)
            .unwrap_or_else(|| field_zero(env))
    }

    pub fn next_leaf_index(&self) -> u32 {
        self.next_leaf_index
    }
}
