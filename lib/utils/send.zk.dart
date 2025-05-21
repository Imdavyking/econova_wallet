// Get recipient wallet address

// Fetch recipient public key from address

// If public key not found
//     Show error and stop

// Encrypt the plain text message using recipient's public key

// Generate zero-knowledge proof to prove sender validity anonymously

// Create message payload containing:
//     - Encrypted message
//     - Zero-knowledge proof 
//     - Recipient address

// Store the message payload on decentralized storage or backend

// Notify recipient about the new message (optional)

// ---

// To receive messages:

// Fetch all messages for recipient’s address

// For each message:
//     Get encrypted message from payload
//     Decrypt message using recipient’s private key
//     Display decrypted message to recipient


// receive(message, zk_proof, public_inputs)

// is_valid = verify_zk_proof(zk_proof, public_inputs)

// if is_valid then
//     decrypted_message = decrypt_message(message, recipient_private_key)
//     display(decrypted_message)
// else
//     reject("Invalid proof - message not trusted")
// end if