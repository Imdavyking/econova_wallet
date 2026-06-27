// field.rs
// BN254 scalar field arithmetic for Soroban
// Used for compatibility with Noir proofs (which use BN254)

use crate::u512::{mont_mul, split_u256};
use soroban_sdk::{Env, U256};

// -------------------------------------------------------
// BN254 prime constants
// -------------------------------------------------------

// 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
pub fn bn254_prime(env: &Env) -> U256 {
    U256::from_parts(
        env,
        0x30644e72e131a029_u64,
        0xb85045b68181585d_u64,
        0x2833e84879b97091_u64,
        0x43e1f593f0000001_u64,
    )
}

// 0x183227397098d014dc2822db40c0ac2ecf17f7f1f01d00000000000000000000
pub fn bn254_prime_div_2(env: &Env) -> U256 {
    U256::from_parts(
        env,
        0x183227397098d014_u64,
        0xdc2822db40c0ac2e_u64,
        0xcf17f7f1f01d0000_u64,
        0x0000000000000000_u64,
    )
}

/// R^2 mod p, where R = 2^256. Precomputed once since it only depends on
/// the fixed BN254 modulus — verified as `(1 << 512) % p` in Python.
/// Used by `field_mul` below.
fn bn254_r2(env: &Env) -> U256 {
    U256::from_parts(
        env,
        0x0216d0b17f4e44a5_u64,
        0x8c49833d53bb8085_u64,
        0x53fe3ab1e35c59e3_u64,
        0x1bb8e645ae216da7_u64,
    )
}

// -------------------------------------------------------
// Precomputed limb arrays for field_mul's hot path.
//
// Same values as bn254_prime()/bn254_r2() above, but as native [u64; 4]
// (little-endian, matching split_u256's output order) so field_mul never
// has to round-trip through U256::from_parts -> to_be_bytes -> Bytes::get()
// (32 host calls each) just to re-derive a constant on every call.
// -------------------------------------------------------

const BN254_P_LIMBS: [u64; 4] = [
    0x43e1f593f0000001_u64,
    0x2833e84879b97091_u64,
    0xb85045b68181585d_u64,
    0x30644e72e131a029_u64,
];

const BN254_R2_LIMBS: [u64; 4] = [
    0x1bb8e645ae216da7_u64,
    0x53fe3ab1e35c59e3_u64,
    0x8c49833d53bb8085_u64,
    0x0216d0b17f4e44a5_u64,
];

/// x^-1 mod 2^64 for odd x, via Newton-Raphson/Hensel lifting. Each
/// iteration doubles the number of correct bits (3 -> 6 -> 12 -> 24 -> 48
/// -> 96), so 5 iterations is exact mod 2^64.
const fn inv_mod_2_64(x: u64) -> u64 {
    let mut y = x;
    let mut i = 0;
    while i < 5 {
        y = y.wrapping_mul(2u64.wrapping_sub(x.wrapping_mul(y)));
        i += 1;
    }
    y
}

/// n0 = -p^-1 mod 2^64, the Montgomery constant for BN254's modulus
/// (derived from p's least-significant limb: 0x43e1f593f0000001).
/// Cross-checked against Python's `pow(p0, -1, 2**64)`: 0xc2e1f593efffffff.
const BN254_N0: u64 = inv_mod_2_64(0x43e1f593f0000001_u64).wrapping_neg();

// -------------------------------------------------------
// Constructors
// -------------------------------------------------------

pub fn field_new(env: &Env, value: U256) -> U256 {
    assert!(value < bn254_prime(env), "Field: input too large");
    value
}

pub fn field_new_unchecked(_env: &Env, value: U256) -> U256 {
    value
}

pub fn field_zero(env: &Env) -> U256 {
    U256::from_u32(env, 0)
}

// -------------------------------------------------------
// Checks
// -------------------------------------------------------

pub fn field_check(env: &Env, value: &U256) {
    assert!(*value < bn254_prime(env), "Field: input too large");
}

pub fn field_is_zero(env: &Env, value: &U256) -> bool {
    *value == field_zero(env)
}

// -------------------------------------------------------
// Arithmetic (mod BN254_PRIME)
// -------------------------------------------------------

/// (a + b) mod p
/// Both inputs < p, so sum overflows by at most one prime — single subtract suffices.
pub fn field_add(env: &Env, a: &U256, b: &U256) -> U256 {
    let sum = a.add(b);
    let p = bn254_prime(env);
    if sum >= p {
        sum.sub(&p)
    } else {
        sum
    }
}

/// (a - b) mod p
pub fn field_sub(env: &Env, a: &U256, b: &U256) -> U256 {
    let p = bn254_prime(env);
    if a >= b {
        a.sub(b)
    } else {
        p.sub(&b.sub(a))
    }
}

/// (a * b) mod p, via CIOS Montgomery multiplication.
///
/// `mont_mul(x, y)` computes `x*y*R^-1 mod p` for `R = 2^256`. Calling it
/// twice cancels the extra `R^-1` and yields plain `a*b mod p`:
///
///   mont_mul(a, b)            = a*b*R^-1                    mod p
///   mont_mul(that, R^2 mod p) = a*b*R^-1 * R^2 * R^-1 mod p = a*b mod p
///
/// `a` and `b` go in and come out as plain U256 — Montgomery form never
/// leaks into the rest of the field API.
///
/// `p` and `r2` are fixed constants, so they're pulled from the
/// precomputed BN254_P_LIMBS/BN254_R2_LIMBS arrays instead of being
/// re-derived from a freshly built U256 (which would cost 32 host calls
/// each via split_u256 -> Bytes::get(), on every single field_mul call).
pub fn field_mul(env: &Env, a: &U256, b: &U256) -> U256 {
    let p = BN254_P_LIMBS;
    let a = split_u256(a);
    let b = split_u256(b);
    let r2 = BN254_R2_LIMBS;

    let step1 = mont_mul(&a, &b, &p, BN254_N0);
    let step2 = mont_mul(&step1, &r2, &p, BN254_N0);

    U256::from_parts(env, step2[3], step2[2], step2[1], step2[0])
}

// -------------------------------------------------------
// Signed interpretation (same as Solidity/Cairo version)
// Returns (is_positive, absolute_value)
// Values > PRIME/2 are treated as negative
// -------------------------------------------------------
pub fn field_signed(env: &Env, value: &U256) -> (bool, U256) {
    let half = bn254_prime_div_2(env);
    if *value > half {
        (false, bn254_prime(env).sub(value))
    } else {
        (true, value.clone())
    }
}
