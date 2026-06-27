use dep::poseidon::poseidon2;

pub fn compute_merkle_root(leaf: Field, merkle_proof: [Field; 8], is_even: [bool; 8]) -> Field {
    // temporary variable to store the hash for the current level we are working on
    let mut hash = leaf;
    // increment through the levels
    for i in 0..8 {
        // if the current level is even, we hash the current hash and the proof
        let (left, right) = if is_even[i] {
            (hash, merkle_proof[i])
        } else {
            (merkle_proof[i], hash)
        };
        // compute the hash for the current level
        hash = poseidon2::Poseidon2::hash([left, right], 2);
    }
    // return the root hash
    hash
}
