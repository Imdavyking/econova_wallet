// Vendored UltraHonk verification logic, folded in as a submodule of the
// contract crate (no longer a separate `ultrahonk_soroban_verifier` crate).
// `#![no_std]` and `extern crate alloc;` live in `lib.rs` (crate root) now —
// both are crate-level declarations and can't be repeated here.

pub mod debug;
pub mod ec;
pub mod field;
pub mod hash;
pub mod relations;
pub mod shplemini;
pub mod sumcheck;
pub mod transcript;
pub mod types;
pub mod utils;
pub mod verifier;

pub const PROOF_FIELDS: usize = 456;
pub const PROOF_BYTES: usize = PROOF_FIELDS * 32;

pub use verifier::{UltraHonkVerifier, VkLoadError};
