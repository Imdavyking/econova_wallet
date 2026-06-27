use soroban_sdk::{Bytes, U256};

#[derive(Clone, Debug)]
pub struct U512 {
    pub limbs: [u64; 8], // little-endian
}

pub(crate) fn split_u256(x: &U256) -> [u64; 4] {
    let bytes: Bytes = x.to_be_bytes();
    let mut arr = [0u8; 32];
    bytes.copy_into_slice(&mut arr); // single host call instead of 32x .get()

    [
        u64::from_be_bytes(arr[24..32].try_into().unwrap()),
        u64::from_be_bytes(arr[16..24].try_into().unwrap()),
        u64::from_be_bytes(arr[8..16].try_into().unwrap()),
        u64::from_be_bytes(arr[0..8].try_into().unwrap()),
    ]
}
pub(crate) fn ge4(a: &[u64; 4], b: &[u64; 4]) -> bool {
    for i in (0..4).rev() {
        if a[i] != b[i] {
            return a[i] > b[i];
        }
    }
    true
}

pub(crate) fn sub4(a: &mut [u64; 4], b: &[u64; 4]) {
    let mut borrow = 0u64;
    for i in 0..4 {
        let (d1, b1) = a[i].overflowing_sub(b[i]);
        let (d2, b2) = d1.overflowing_sub(borrow);
        a[i] = d2;
        borrow = (b1 as u64) + (b2 as u64);
    }
}

/// 256x256 -> 512 bit product, via product-scanning ("Comba") multiplication.
///
/// Each output limb `out[k]` is the sum of one antidiagonal of the
/// `a[i]*b[j]` grid (all pairs with `i+j == k`), so it's written exactly
/// once — unlike row-by-row schoolbook multiplication, which touches the
/// same `out[k]` from several different outer-loop iterations and needs a
/// second carry-propagation pass afterward. Same 16 total multiplications
/// either way (that's the minimum for a 4x4-limb schoolbook product —
/// Karatsuba would trade some of them for extra add/sub bookkeeping, which
/// isn't a clear win at this size), but fewer redundant reads/writes of
/// `out` and no separate carry-fixup loop.
///
/// A column can sum up to 4 partial products, each almost 2^128, so a
/// plain `u128` accumulator can overflow if added to naively. We track
/// each overflow explicitly (`extra`, at most 4) and fold it back in as
/// the high half of the carry into the next column.
pub fn wide_mul_u256(a: &U256, b: &U256) -> U512 {
    let a = split_u256(a);
    let b = split_u256(b);

    let mut out = [0u64; 8];
    let mut carry: u128 = 0;

    for k in 0usize..8 {
        let lo = k.saturating_sub(3);
        let hi = k.min(3);

        let mut acc = carry;
        let mut extra: u64 = 0;

        for i in lo..=hi {
            let j = k - i;
            let prod = (a[i] as u128) * (b[j] as u128);
            let (sum, overflowed) = acc.overflowing_add(prod);
            acc = sum;
            extra += overflowed as u64;
        }

        out[k] = acc as u64;
        carry = (acc >> 64) | ((extra as u128) << 64);
    }

    U512 { limbs: out }
}

/// Remainder of 512-bit `x` divided by 256-bit `m`, via bit-serial
/// restoring division. Still here as a general-purpose utility (e.g. for
/// a future extended-Euclid `field_inverse`), but `field_mul` no longer
/// uses it — see the CIOS note below.
pub fn u512_rem_u256(x: &[u64; 8], m: &[u64; 4]) -> [u64; 4] {
    let mut r = [0u64; 4];
    let mut r4: u64 = 0;

    for i in (0..8).rev() {
        for b in (0..64).rev() {
            let bit = (x[i] >> b) & 1;

            r4 = (r4 << 1) | (r[3] >> 63);
            r[3] = (r[3] << 1) | (r[2] >> 63);
            r[2] = (r[2] << 1) | (r[1] >> 63);
            r[1] = (r[1] << 1) | (r[0] >> 63);
            r[0] = (r[0] << 1) | bit;

            if r4 == 1 || ge4(&r, m) {
                sub4(&mut r, m);
                r4 = 0;
            }
        }
    }
    r
}

/// CIOS Montgomery multiplication: computes `a*b*R^-1 mod n` for `R = 2^256`,
/// entirely in terms of 64-bit limb multiply-adds — the 512-bit product
/// is never materialized, and there's no division. `n0` must be
/// `-n[0]^-1 mod 2^64` for the modulus `n`. Requires `a, b < n`.
pub(crate) fn mont_mul(a: &[u64; 4], b: &[u64; 4], n: &[u64; 4], n0: u64) -> [u64; 4] {
    let mut t = [0u64; 6]; // 4 limbs + 2 carry/overflow slots

    for i in 0..4 {
        let mut c: u128 = 0;
        for j in 0..4 {
            let sum = t[j] as u128 + (a[j] as u128) * (b[i] as u128) + c;
            t[j] = sum as u64;
            c = sum >> 64;
        }
        let sum = t[4] as u128 + c;
        t[4] = sum as u64;
        t[5] = (sum >> 64) as u64;

        let m = t[0].wrapping_mul(n0);

        let sum = t[0] as u128 + (m as u128) * (n[0] as u128);
        let mut c = sum >> 64;
        for j in 1..4 {
            let sum = t[j] as u128 + (m as u128) * (n[j] as u128) + c;
            t[j - 1] = sum as u64;
            c = sum >> 64;
        }
        let sum = t[4] as u128 + c;
        t[3] = sum as u64;
        t[4] = t[5] + (sum >> 64) as u64;
    }

    let mut result = [t[0], t[1], t[2], t[3]];
    if t[4] != 0 || ge4(&result, n) {
        sub4(&mut result, n);
    }
    result
}
