use dep::poseidon::poseidon2;
mod merkle_tree;

fn main(
    // public inputs
    root: pub Field,
    nullifier_hash: pub Field,
    recipient_hash: pub Field,
    // private inputs
    recipient: Field,
    secret: Field,
    nullifier: Field,
    merkle_proof: [Field; 8],
    is_even: [bool; 8],
) {
    // compute the commitment Poseidon(nullifier, secret)
    let commitment = poseidon2::Poseidon2::hash([nullifier, secret], 2);
    // check that the nullfier matches the nullifier hash
    let computed_nullifier_hash = poseidon2::Poseidon2::hash([nullifier], 1);
    assert(
        computed_nullifier_hash == nullifier_hash,
        "Computed nullifier hash does not match the provided nullifier hash",
    );
    //check the commitment is in the merkle tree
    let computed_root = merkle_tree::compute_merkle_root(commitment, merkle_proof, is_even);
    assert(computed_root == root, "Computed root does not match the provided root");
    // check that the recipient matches the recipient binding
    let computed_recipient_hash = poseidon2::Poseidon2::hash([recipient], 1);
    assert(
        computed_recipient_hash == recipient_hash,
        "Computed recipient_hash does not match the provided recipient_hash",
    );
}
