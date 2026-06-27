// poseidon2lib.rs
// Poseidon2 hash function over BN254 scalar field — Soroban implementation
// Constants re-split from Cairo source (ground truth) to fix u64 overflow bugs.

#![allow(dead_code)]

use soroban_sdk::{Env, Vec, U256};

use crate::field::{field_add, field_mul, field_new_unchecked, field_zero};

const T: usize = 4;
const ROUNDS_F: usize = 8;
const ROUNDS_P: usize = 56;
const RATE: usize = 3;
const TOTAL_ROUNDS: usize = 64;

struct Sponge {
    iv: U256,
    cache: Vec<U256>,
    state: Vec<U256>,
    cache_size: usize,
    squeeze_mode: bool,
}

pub struct Poseidon2;

impl Poseidon2 {
    pub fn hash_1(env: &Env, m: U256) -> U256 {
        let mut inputs = Vec::new(env);
        inputs.push_back(m);
        hash_internal(env, inputs, 1, false)
    }

    pub fn hash_2(env: &Env, m1: U256, m2: U256) -> U256 {
        let mut inputs = Vec::new(env);
        inputs.push_back(m1);
        inputs.push_back(m2);
        hash_internal(env, inputs, 2, false)
    }

    pub fn hash_3(env: &Env, m1: U256, m2: U256, m3: U256) -> U256 {
        let mut inputs = Vec::new(env);
        inputs.push_back(m1);
        inputs.push_back(m2);
        inputs.push_back(m3);
        hash_internal(env, inputs, 3, false)
    }

    pub fn hash(
        env: &Env,
        inputs: Vec<U256>,
        std_input_length: usize,
        is_variable_length: bool,
    ) -> U256 {
        hash_internal(env, inputs, std_input_length, is_variable_length)
    }
}

fn hash_internal(
    env: &Env,
    input: Vec<U256>,
    std_input_length: usize,
    is_variable_length: bool,
) -> U256 {
    let iv = generate_iv(env, input.len() as usize);
    let mut sponge = new_sponge(env, iv);

    let len = input.len() as usize;
    let mut i = 0usize;
    while i < len {
        if i < std_input_length {
            absorb(env, &mut sponge, input.get(i as u32).unwrap());
        }
        i += 1;
    }

    if is_variable_length {
        absorb(
            env,
            &mut sponge,
            field_new_unchecked(env, U256::from_u32(env, 1)),
        );
    }

    squeeze(env, &mut sponge)
}

fn generate_iv(env: &Env, input_length: usize) -> U256 {
    let len_u256 = U256::from_u32(env, input_length as u32);
    // Plain shift left by 64 bits — no field reduction needed
    let shift = U256::from_parts(
        env,
        0x0000000000000000_u64,
        0x0000000000000000_u64,
        0x0000000000000001_u64, // 2^64
        0x0000000000000000_u64,
    );
    len_u256.mul(&shift) // plain U256 multiply, not field_mul
}

fn new_sponge(env: &Env, iv: U256) -> Sponge {
    let zero = field_zero(env);
    let mut state = Vec::new(env);
    state.push_back(zero.clone());
    state.push_back(zero.clone());
    state.push_back(zero.clone());
    state.push_back(iv.clone());

    let mut cache = Vec::new(env);
    cache.push_back(zero.clone());
    cache.push_back(zero.clone());
    cache.push_back(zero.clone());

    Sponge {
        iv,
        cache,
        state,
        cache_size: 0,
        squeeze_mode: false,
    }
}

fn absorb(env: &Env, sponge: &mut Sponge, input: U256) {
    if !sponge.squeeze_mode && sponge.cache_size == RATE {
        perform_duplex(env, sponge);
        let zero = field_zero(env);
        let mut new_cache = Vec::new(env);
        new_cache.push_back(input);
        new_cache.push_back(zero.clone());
        new_cache.push_back(zero.clone());
        sponge.cache = new_cache;
        sponge.cache_size = 1;
    } else if !sponge.squeeze_mode && sponge.cache_size < RATE {
        let zero = field_zero(env);
        let mut new_cache = Vec::new(env);
        let mut j = 0usize;
        while j < RATE {
            if j < sponge.cache_size {
                new_cache.push_back(sponge.cache.get(j as u32).unwrap());
            } else if j == sponge.cache_size {
                new_cache.push_back(input.clone());
            } else {
                new_cache.push_back(zero.clone());
            }
            j += 1;
        }
        sponge.cache = new_cache;
        sponge.cache_size += 1;
    }
}

fn squeeze(env: &Env, sponge: &mut Sponge) -> U256 {
    if !sponge.squeeze_mode {
        let output = perform_duplex(env, sponge);
        sponge.squeeze_mode = true;
        sponge.cache = output;
        sponge.cache_size = RATE;
    }

    let result = sponge.cache.get(0).unwrap();
    let zero = field_zero(env);
    let mut new_cache = Vec::new(env);
    let mut i = 1usize;
    while i < RATE {
        if i < sponge.cache_size {
            new_cache.push_back(sponge.cache.get(i as u32).unwrap());
        } else {
            new_cache.push_back(zero.clone());
        }
        i += 1;
    }
    new_cache.push_back(zero.clone());
    sponge.cache = new_cache;
    sponge.cache_size -= 1;

    result
}

fn perform_duplex(env: &Env, sponge: &mut Sponge) -> Vec<U256> {
    let zero = field_zero(env);
    let mut new_state = Vec::new(env);
    let mut i = 0usize;
    while i < T {
        if i < RATE {
            let cache_val = if i < sponge.cache_size {
                sponge.cache.get(i as u32).unwrap()
            } else {
                zero.clone()
            };
            let s = sponge.state.get(i as u32).unwrap();
            new_state.push_back(field_add(env, &s, &cache_val));
        } else {
            new_state.push_back(sponge.state.get(i as u32).unwrap());
        }
        i += 1;
    }
    sponge.state = new_state;
    sponge.state = permutation(env, &sponge.state);

    let mut out = Vec::new(env);
    out.push_back(sponge.state.get(0).unwrap());
    out.push_back(sponge.state.get(1).unwrap());
    out.push_back(sponge.state.get(2).unwrap());
    out
}

fn permutation(env: &Env, inputs: &Vec<U256>) -> Vec<U256> {
    let mut state = Vec::new(env);
    state.push_back(inputs.get(0).unwrap());
    state.push_back(inputs.get(1).unwrap());
    state.push_back(inputs.get(2).unwrap());
    state.push_back(inputs.get(3).unwrap());

    matrix_multiplication_4x4(env, &mut state);

    let rf_first = ROUNDS_F / 2; // 4
    let mut r = 0usize;
    while r < rf_first {
        add_round_constants(env, &mut state, r);
        s_box_full(env, &mut state);
        matrix_multiplication_4x4(env, &mut state);
        r += 1;
    }

    let p_end = rf_first + ROUNDS_P; // 60
    let mut r = rf_first;
    while r < p_end {
        let rc = round_constant_0(env, r);
        let s0 = state.get(0).unwrap();
        let new_s0 = single_box(env, field_add(env, &s0, &rc));
        let s1 = state.get(1).unwrap();
        let s2 = state.get(2).unwrap();
        let s3 = state.get(3).unwrap();
        let mut new_state = Vec::new(env);
        new_state.push_back(new_s0);
        new_state.push_back(s1);
        new_state.push_back(s2);
        new_state.push_back(s3);
        state = new_state;
        internal_m_multiplication(env, &mut state);
        r += 1;
    }

    let num_rounds = ROUNDS_F + ROUNDS_P; // 64
    let mut r = p_end;
    while r < num_rounds {
        add_round_constants(env, &mut state, r);
        s_box_full(env, &mut state);
        matrix_multiplication_4x4(env, &mut state);
        r += 1;
    }

    state
}

fn single_box(env: &Env, x: U256) -> U256 {
    let s = field_mul(env, &x, &x); // x^2
    let s2 = field_mul(env, &s, &s); // x^4
    field_mul(env, &s2, &x) // x^5
}

fn s_box_full(env: &Env, state: &mut Vec<U256>) {
    let s0 = single_box(env, state.get(0).unwrap());
    let s1 = single_box(env, state.get(1).unwrap());
    let s2 = single_box(env, state.get(2).unwrap());
    let s3 = single_box(env, state.get(3).unwrap());
    let mut new_state = Vec::new(env);
    new_state.push_back(s0);
    new_state.push_back(s1);
    new_state.push_back(s2);
    new_state.push_back(s3);
    *state = new_state;
}

fn matrix_multiplication_4x4(env: &Env, input: &mut Vec<U256>) {
    let a = input.get(0).unwrap();
    let b = input.get(1).unwrap();
    let c = input.get(2).unwrap();
    let d = input.get(3).unwrap();

    let t0 = field_add(env, &a, &b);
    let t1 = field_add(env, &c, &d);
    let t2 = field_add(env, &field_add(env, &b, &b), &t1);
    let t3 = field_add(env, &field_add(env, &d, &d), &t0);
    let t4 = field_add(
        env,
        &field_add(env, &field_add(env, &t1, &t1), &field_add(env, &t1, &t1)),
        &t3,
    );
    let t5 = field_add(
        env,
        &field_add(env, &field_add(env, &t0, &t0), &field_add(env, &t0, &t0)),
        &t2,
    );
    let t6 = field_add(env, &t3, &t5);
    let t7 = field_add(env, &t2, &t4);

    let mut new_state = Vec::new(env);
    new_state.push_back(t6);
    new_state.push_back(t5);
    new_state.push_back(t7);
    new_state.push_back(t4);
    *input = new_state;
}

fn internal_m_multiplication(env: &Env, input: &mut Vec<U256>) {
    let diag = internal_matrix_diagonal(env);
    let s01 = field_add(env, &input.get(0).unwrap(), &input.get(1).unwrap());
    let s23 = field_add(env, &input.get(2).unwrap(), &input.get(3).unwrap());
    let sum = field_add(env, &s01, &s23);

    let mut new_state = Vec::new(env);
    let mut i = 0usize;
    while i < T {
        let xi = input.get(i as u32).unwrap();
        let di = diag.get(i as u32).unwrap();
        let term = field_mul(env, &xi, &di);
        new_state.push_back(field_add(env, &term, &sum));
        i += 1;
    }
    *input = new_state;
}

fn add_round_constants(env: &Env, state: &mut Vec<U256>, round: usize) {
    let rc = round_constants_full(env, round);
    let mut new_state = Vec::new(env);
    let mut i = 0usize;
    while i < T {
        let s = state.get(i as u32).unwrap();
        let r = rc.get(i as u32).unwrap();
        new_state.push_back(field_add(env, &s, &r));
        i += 1;
    }
    *state = new_state;
}

fn round_constant_0(env: &Env, round: usize) -> U256 {
    match round {
        4 => U256::from_parts(
            env,
            0x0c6f8f958be0e930_u64,
            0x53d7fd4fc5451285_u64,
            0x5535ed1539f051dc_u64,
            0xb43a26fd926361cf_u64,
        ),
        5 => U256::from_parts(
            env,
            0x123106a93cd17578_u64,
            0xd426e8128ac9d90a_u64,
            0xa9e8a00708e296e0_u64,
            0x84dd57e69caaf811_u64,
        ),
        6 => U256::from_parts(
            env,
            0x26e1ba52ad9285d9_u64,
            0x7dd3ab52f8e84008_u64,
            0x5e8fa83ff1e8f187_u64,
            0x7b074867cd2dee75_u64,
        ),
        7 => U256::from_parts(
            env,
            0x1cb55cad7bd133de_u64,
            0x18a64c5c47b9c97c_u64,
            0xbe4d8b7bf9e09586_u64,
            0x4471537e6a4ae2c5_u64,
        ),
        8 => U256::from_parts(
            env,
            0x1dcd73e46acd8f8e_u64,
            0x0e2c7ce04bde7f6d_u64,
            0x2a53043d5060a41c_u64,
            0x7143f08e6e9055d0_u64,
        ),
        9 => U256::from_parts(
            env,
            0x011003e32f6d9c66_u64,
            0xf5852f05474a4def_u64,
            0x0cda294a0eb4e9b9_u64,
            0xb12b9bb4512e5574_u64,
        ),
        10 => U256::from_parts(
            env,
            0x2b1e809ac1d10ab2_u64,
            0x9ad5f20d03a57dfe_u64,
            0xbadfe5903f58bafe_u64,
            0xd7c508dd2287ae8c_u64,
        ),
        11 => U256::from_parts(
            env,
            0x2539de1785b73599_u64,
            0x9fb4dac35ee17ed0_u64,
            0xef995d05ab2fc5fa_u64,
            0xeaa69ae87bcec0a5_u64,
        ),
        12 => U256::from_parts(
            env,
            0x0c246c5a2ef8ee01_u64,
            0x26497f222b3e0a0e_u64,
            0xf4e1c3d41c86d46e_u64,
            0x43982cb11d77951d_u64,
        ),
        13 => U256::from_parts(
            env,
            0x192089c4974f68e9_u64,
            0x5408148f7c0632ed_u64,
            0xbb09e6a6ad1a1c2f_u64,
            0x3f0305f5d03b527b_u64,
        ),
        14 => U256::from_parts(
            env,
            0x1eae0ad8ab68b2f0_u64,
            0x6a0ee36eeb0d0c05_u64,
            0x8529097d91096b75_u64,
            0x6d8fdc2fb5a60d85_u64,
        ),
        15 => U256::from_parts(
            env,
            0x179190e5d0e22179_u64,
            0xe46f8282872abc88_u64,
            0xdb6e2fdc0dee99e6_u64,
            0x9768bd98c5d06bfb_u64,
        ),
        16 => U256::from_parts(
            env,
            0x29bb9e2c90767325_u64,
            0x76e9a81c7ac4b832_u64,
            0x14528f7db00f31bf_u64,
            0x6cafe794a9b3cd1c_u64,
        ),
        17 => U256::from_parts(
            env,
            0x225d394e42207599_u64,
            0x403efd0c2464a90d_u64,
            0x52652645882aac35_u64,
            0xb10e590e6e691e08_u64,
        ),
        18 => U256::from_parts(
            env,
            0x064760623c25c8cf_u64,
            0x753d238055b44453_u64,
            0x2be13557451c087d_u64,
            0xe09efd454b23fd59_u64,
        ),
        19 => U256::from_parts(
            env,
            0x10ba3a0e01df92e8_u64,
            0x7f301c4b716d8a39_u64,
            0x4d67f4bf42a75c10_u64,
            0x922910a78f6b5b87_u64,
        ),
        20 => U256::from_parts(
            env,
            0x0e070bf53f8451b2_u64,
            0x4f9c6e96b0c2a801_u64,
            0xcb511bc0c242eb9d_u64,
            0x361b77693f21471c_u64,
        ),
        21 => U256::from_parts(
            env,
            0x1b94cd61b051b04d_u64,
            0xd39755ff93821a73_u64,
            0xccd6cb11d2491d8a_u64,
            0xa7f921014de252fb_u64,
        ),
        22 => U256::from_parts(
            env,
            0x1d7cb39bafb8c744_u64,
            0xe148787a2e70230f_u64,
            0x9d4e917d5713bb05_u64,
            0x0487b5aa7d74070b_u64,
        ),
        23 => U256::from_parts(
            env,
            0x2ec93189bd1ab4f6_u64,
            0x9117d0fe980c80ff_u64,
            0x8785c2961829f701_u64,
            0xbb74ac1f303b17db_u64,
        ),
        24 => U256::from_parts(
            env,
            0x2db366bfdd36d277_u64,
            0xa692bb825b86275b_u64,
            0xeac404a19ae07a90_u64,
            0x82ea46bd83517926_u64,
        ),
        25 => U256::from_parts(
            env,
            0x062100eb485db062_u64,
            0x69655cf186a68532_u64,
            0x985275428450359a_u64,
            0xdc99cec6960711b8_u64,
        ),
        26 => U256::from_parts(
            env,
            0x0761d33c66614aaa_u64,
            0x570e7f1e8244ca11_u64,
            0x20243f92fa59e4f9_u64,
            0x00c567bf41f5a59b_u64,
        ),
        27 => U256::from_parts(
            env,
            0x20fc411a114d1399_u64,
            0x2c2705aa034e3f31_u64,
            0x5d78608a0f7de4cc_u64,
            0xf7a72e494855ad0d_u64,
        ),
        28 => U256::from_parts(
            env,
            0x25b5c004a4bdfcb5_u64,
            0xadd9ec4e9ab219ba_u64,
            0x102c67e8b3effb5f_u64,
            0xc3a30f317250bc5a_u64,
        ),
        29 => U256::from_parts(
            env,
            0x23b1822d278ed632_u64,
            0xa494e58f6df6f5ed_u64,
            0x038b186d8474155a_u64,
            0xd87e7dff62b37f4b_u64,
        ),
        30 => U256::from_parts(
            env,
            0x22734b4c5c3f9493_u64,
            0x606c4ba9012499bf_u64,
            0x0f14d13bfcfcccaa_u64,
            0x16102a29cc2f69e0_u64,
        ),
        31 => U256::from_parts(
            env,
            0x26c0c8fe09eb30b7_u64,
            0xe27a74dc33492347_u64,
            0xe5bdff409aa36102_u64,
            0x54413d3fad795ce5_u64,
        ),
        32 => U256::from_parts(
            env,
            0x070dd0ccb6bd7bba_u64,
            0xe88eac03fa1fbb26_u64,
            0x196be3083a809829_u64,
            0xbbd626df348ccad9_u64,
        ),
        33 => U256::from_parts(
            env,
            0x12b6595bdb329b6f_u64,
            0xb043ba78bb28c3be_u64,
            0xc2c0a6de46d8c5ad_u64,
            0x6067c4ebfd4250da_u64,
        ),
        34 => U256::from_parts(
            env,
            0x248d97d7f76283d6_u64,
            0x3bec30e7a5876c11_u64,
            0xc06fca9b275c671c_u64,
            0x5e33d95bb7e8d729_u64,
        ),
        35 => U256::from_parts(
            env,
            0x1a306d439d463b08_u64,
            0x16fc6fd64cc93931_u64,
            0x8b45eb759ddde4aa_u64,
            0x106d15d9bd9baaaa_u64,
        ),
        36 => U256::from_parts(
            env,
            0x28a8f8372e3c38da_u64,
            0xced7c00421cb4621_u64,
            0xf4f1b54ddc27821b_u64,
            0x0d62d3d6ec7c56cf_u64,
        ),
        37 => U256::from_parts(
            env,
            0x0094975717f9a8a8_u64,
            0xbb35152f24d43294_u64,
            0x071ce320c829f388_u64,
            0xbc852183e1e2ce7e_u64,
        ),
        38 => U256::from_parts(
            env,
            0x04d5ee4c3aa78f7d_u64,
            0x80fde60d716480d3_u64,
            0x593f74d4f653ae83_u64,
            0xf4103246db2e8d65_u64,
        ),
        39 => U256::from_parts(
            env,
            0x2a6cf5e9aa03d433_u64,
            0x6349ad6fb8ed2269_u64,
            0xc7bef54b8822cc76_u64,
            0xd08495c12efde187_u64,
        ),
        40 => U256::from_parts(
            env,
            0x2304d31eaab960ba_u64,
            0x9274da43e19ddeb7_u64,
            0xf792180808fd6e43_u64,
            0xbaae48d7efcba3f3_u64,
        ),
        41 => U256::from_parts(
            env,
            0x03fd9ac865a4b2a6_u64,
            0xd5e7009785817249_u64,
            0xbff08a7e0726fcb4_u64,
            0xe1c11d39d199f0b0_u64,
        ),
        42 => U256::from_parts(
            env,
            0x00b7258ded52bbda_u64,
            0x2248404d55ee5044_u64,
            0x798afc3a20919307_u64,
            0x3f7954d4d63b0b64_u64,
        ),
        43 => U256::from_parts(
            env,
            0x159f81ada0771799_u64,
            0xec38fca2d4bf65eb_u64,
            0xb13d3a74f3298db3_u64,
            0x6272c5ca65e92d9a_u64,
        ),
        44 => U256::from_parts(
            env,
            0x1ef90e67437fbc85_u64,
            0x50237a75bc28e3bb_u64,
            0x9000130ea25f0c54_u64,
            0x71e144cf4264431f_u64,
        ),
        45 => U256::from_parts(
            env,
            0x1e65f838515e5ff0_u64,
            0x196b49aa41a2d256_u64,
            0x8df739bc176b08ec_u64,
            0x95a79ed82932e30d_u64,
        ),
        46 => U256::from_parts(
            env,
            0x2b1b045def3a166c_u64,
            0xec6ce768d079ba74_u64,
            0xb18c844e570e1f82_u64,
            0x6575c1068c94c33f_u64,
        ),
        47 => U256::from_parts(
            env,
            0x0832e5753ceb0ff6_u64,
            0x402543b1109229c1_u64,
            0x65dc2d73bef715e3_u64,
            0xf1c6e07c168bb173_u64,
        ),
        48 => U256::from_parts(
            env,
            0x02f614e9cedfb3dc_u64,
            0x6b762ae0a37d41ba_u64,
            0xb1b841c2e8b6451b_u64,
            0xc5a8e3c390b6ad16_u64,
        ),
        49 => U256::from_parts(
            env,
            0x0e2427d38bd46a60_u64,
            0xdd640b8e362cad96_u64,
            0x7370ebb777bedff4_u64,
            0x0f6a0be27e7ed705_u64,
        ),
        50 => U256::from_parts(
            env,
            0x0493630b7c670b6d_u64,
            0xeb7c84d414e7ce79_u64,
            0x049f0ec098c3c7c5_u64,
            0x0768bbe29214a53a_u64,
        ),
        51 => U256::from_parts(
            env,
            0x22ead100e8e48267_u64,
            0x4decdab17066c5a2_u64,
            0x6bb1515355d5461a_u64,
            0x3dc06cc85327cea9_u64,
        ),
        52 => U256::from_parts(
            env,
            0x25b3e56e655b42cd_u64,
            0xaae2626ed2554d48_u64,
            0x583f1ae35626d04d_u64,
            0xe5084e0b6d2a6f16_u64,
        ),
        53 => U256::from_parts(
            env,
            0x1e32752ada8836ef_u64,
            0x5837a6cde8ff13db_u64,
            0xb599c336349e4c58_u64,
            0x4b4fdc0a0cf6f9d0_u64,
        ),
        54 => U256::from_parts(
            env,
            0x2fa2a871c15a387c_u64,
            0xc50f68f6f3c3455b_u64,
            0x23c00995f05078f6_u64,
            0x72a9864074d412e5_u64,
        ),
        55 => U256::from_parts(
            env,
            0x2f569b8a9a4424c9_u64,
            0x278e1db7311e889f_u64,
            0x54ccbf10661bab7f_u64,
            0xcd18e7c7a7d83505_u64,
        ),
        56 => U256::from_parts(
            env,
            0x044cb455110a8fdd_u64,
            0x531ade530234c518_u64,
            0xa7df93f7332ffd21_u64,
            0x44165374b246b43d_u64,
        ),
        57 => U256::from_parts(
            env,
            0x227808de93906d5d_u64,
            0x420246157f2e42b1_u64,
            0x91fe8c90adfe1181_u64,
            0x78ddc723a5319025_u64,
        ),
        58 => U256::from_parts(
            env,
            0x02fcca2934e046bc_u64,
            0x623adead87357986_u64,
            0x5d03781ae090ad4a_u64,
            0x8579d2e7a6800355_u64,
        ),
        59 => U256::from_parts(
            env,
            0x0ef915f0ac120b87_u64,
            0x6abccceb344a1d36_u64,
            0xbad3f3c5ab91a8dd_u64,
            0xcbec2e060d8befac_u64,
        ),
        _ => U256::from_u32(env, 0),
    }
}

fn round_constants_full(env: &Env, round: usize) -> Vec<U256> {
    let (c0, c1, c2, c3): (
        (u64, u64, u64, u64),
        (u64, u64, u64, u64),
        (u64, u64, u64, u64),
        (u64, u64, u64, u64),
    ) = match round {
        0 => (
            (
                0x19b849f69450b068_u64,
                0x48da1d39bd5e4a43_u64,
                0x02bb86744edc2623_u64,
                0x8b0878e269ed23e5_u64,
            ),
            (
                0x265ddfe127dd51bd_u64,
                0x7239347b758f0a13_u64,
                0x20eb2cc7450acc1d_u64,
                0xad47f80c8dcf34d6_u64,
            ),
            (
                0x199750ec472f1809_u64,
                0xe0f66a545e1e5162_u64,
                0x4108ac845015c2aa_u64,
                0x3dfc36bab497d8aa_u64,
            ),
            (
                0x157ff3fe65ac7208_u64,
                0x110f06a5f74302b1_u64,
                0x4d743ea25067f0ff_u64,
                0xd032f787c7f1cdf8_u64,
            ),
        ),
        1 => (
            (
                0x2e49c43c4569dd9c_u64,
                0x5fd35ac45fca33f1_u64,
                0x0b15c590692f8bee_u64,
                0xfe18f4896ac94902_u64,
            ),
            (
                0x0e35fb8998189052_u64,
                0x0d4aef2b6d6506c3_u64,
                0xcb2f0b6973c24fa8_u64,
                0x2731345ffa2d1f1e_u64,
            ),
            (
                0x251ad47cb15c4f11_u64,
                0x05f109ae5e944f1b_u64,
                0xa9d9e7806d667ffe_u64,
                0xc6fe723002e0b996_u64,
            ),
            (
                0x13da07dc64d42836_u64,
                0x9873e97160234641_u64,
                0xf8beb56fdd05e5f3_u64,
                0x563fa39d9c22df4e_u64,
            ),
        ),
        2 => (
            (
                0x0c009b84e650e6d2_u64,
                0x3dc00c7dccef7483_u64,
                0xa553939689d350cd_u64,
                0x46e7b89055fd4738_u64,
            ),
            (
                0x011f16b1c63a854f_u64,
                0x01992e3956f42d8b_u64,
                0x04eb650c6d535eb0_u64,
                0x203dec74befdca06_u64,
            ),
            (
                0x0ed69e5e383a688f_u64,
                0x209d9a561daa7961_u64,
                0x2f3f78d0467ad454_u64,
                0x85df07093f367549_u64,
            ),
            (
                0x04dba94a7b0ce9e2_u64,
                0x21acad41472b6bbe_u64,
                0x3aec507f5eb3d33f_u64,
                0x463672264c9f789b_u64,
            ),
        ),
        3 => (
            (
                0x0a3f2637d840f3a1_u64,
                0x6eb094271c9d237b_u64,
                0x6036757d4bb50bf7_u64,
                0xce732ff1d4fa28e8_u64,
            ),
            (
                0x259a666f129eea19_u64,
                0x8f8a1c502fdb38fa_u64,
                0x39b1f075569564b6_u64,
                0xe54a485d1182323f_u64,
            ),
            (
                0x28bf7459c9b2f4c6_u64,
                0xd8e7d06a4ee3a47f_u64,
                0x7745d4271038e515_u64,
                0x7a32fdf7ede0d6a1_u64,
            ),
            (
                0x0a1ca941f0570375_u64,
                0x26ea200f489be8d4_u64,
                0xc37c85bbcce6a2ae_u64,
                0xec91bd6941432447_u64,
            ),
        ),
        60 => (
            (
                0x1797130f4b7a3e17_u64,
                0x77eb757bc6f287f6_u64,
                0xab0fb85f6be63b09_u64,
                0xf3b16ef2b1405d38_u64,
            ),
            (
                0x0a76225dc04170ae_u64,
                0x3306c85abab59e60_u64,
                0x8c7f497c20156d4d_u64,
                0x36c668555decc6e5_u64,
            ),
            (
                0x1fffb9ec1992d66b_u64,
                0xa1e77a7b93209af6_u64,
                0xf8fa76d48acb6647_u64,
                0x96174b5326a31a5c_u64,
            ),
            (
                0x25721c4fc15a3f28_u64,
                0x53b57c338fa538d8_u64,
                0x5f8fbba6c6b9c609_u64,
                0x0611889b797b9c5f_u64,
            ),
        ),
        61 => (
            (
                0x0c817fd42d5f7a41_u64,
                0x215e3d07ba197216_u64,
                0xadb4c3790705da95_u64,
                0xeb63b982bfcaf75a_u64,
            ),
            (
                0x13abe3f5239915d3_u64,
                0x9f7e13c2c24970b6_u64,
                0xdf8cf86ce00a2200_u64,
                0x2bc15866e52b5a96_u64,
            ),
            (
                0x2106feea546224ea_u64,
                0x12ef7f39987a46c8_u64,
                0x5c1bc3dc29bdbd7a_u64,
                0x92cd60acb4d391ce_u64,
            ),
            (
                0x21ca859468a746b6_u64,
                0xaaa79474a37dab49_u64,
                0xf1ca5a28c748bc71_u64,
                0x57e1b3345bb0f959_u64,
            ),
        ),
        62 => (
            (
                0x05ccd6255c1e6f0c_u64,
                0x5cf1f0df934194c6_u64,
                0x2911d14d0321662a_u64,
                0x8f1a48999e34185b_u64,
            ),
            (
                0x0f0e34a64b70a626_u64,
                0xe464d846674c4c88_u64,
                0x16c4fb267fe44fe6_u64,
                0xea28678cb09490a4_u64,
            ),
            (
                0x0558531a4e25470c_u64,
                0x6157794ca36d0e96_u64,
                0x47dbfcfe350d6483_u64,
                0x8f5b1a8a2de0d4bf_u64,
            ),
            (
                0x09d3dca9173ed2fa_u64,
                0xceea125157683d18_u64,
                0x924cadad3f655a60_u64,
                0xb72f5864961f1455_u64,
            ),
        ),
        63 => (
            (
                0x0328cbd54e8c0913_u64,
                0x493f866ed03d218b_u64,
                0xf23f92d68aaec486_u64,
                0x17d4c722e5bd4335_u64,
            ),
            (
                0x2bf07216e2aff0a2_u64,
                0x23a487b1a7094e07_u64,
                0xe79e7bcc9798c648_u64,
                0xee3347dd5329d34b_u64,
            ),
            (
                0x1daf345a58006b73_u64,
                0x6499c583cb76c316_u64,
                0xd6f78ed6a6dffc82_u64,
                0x111e11a63fe412df_u64,
            ),
            (
                0x176563472456aaa7_u64,
                0x46b694c60e182361_u64,
                0x1ef39039b2edc7ff_u64,
                0x391e6f2293d2c404_u64,
            ),
        ),
        _ => ((0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)),
    };

    let mut out = Vec::new(env);
    out.push_back(U256::from_parts(env, c0.0, c0.1, c0.2, c0.3));
    out.push_back(U256::from_parts(env, c1.0, c1.1, c1.2, c1.3));
    out.push_back(U256::from_parts(env, c2.0, c2.1, c2.2, c2.3));
    out.push_back(U256::from_parts(env, c3.0, c3.1, c3.2, c3.3));
    out
}

fn internal_matrix_diagonal(env: &Env) -> Vec<U256> {
    let mut diag = Vec::new(env);
    diag.push_back(U256::from_parts(
        env,
        0x10dc6e9c006ea38b_u64,
        0x04b1e03b4bd9490c_u64,
        0x0d03f98929ca1d7f_u64,
        0xb56821fd19d3b6e7_u64,
    ));
    diag.push_back(U256::from_parts(
        env,
        0x0c28145b6a44df3e_u64,
        0x0149b3d0a30b3bb5_u64,
        0x99df9756d4dd9b84_u64,
        0xa86b38cfb45a740b_u64,
    ));
    diag.push_back(U256::from_parts(
        env,
        0x00544b8338791518_u64,
        0xb2c7645a50392798_u64,
        0xb21f75bb60e35961_u64,
        0x70067d00141cac15_u64,
    ));
    diag.push_back(U256::from_parts(
        env,
        0x222c01175718386f_u64,
        0x2e2e82eb122789e3_u64,
        0x52e105a3b8fa8526_u64,
        0x13bc534433ee428b_u64,
    ));
    diag
}
