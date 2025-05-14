import 'package:solana/solana.dart';

const FAVORITE_DOMAIN_SEED = "favourite_domain";
const HASH_PREFIX = "SPL Name Service";
final FEE_OWNER = Ed25519HDPublicKey.fromBase58(
    "GcWEQ9K78FV7LEHteFVciYApERk5YvQuFDQPk1yYJVXi");
final NAME_OFFERS_ID = Ed25519HDPublicKey.fromBase58(
    "85iDfUvr3HJyLM2zcq5BXSiDvUWfw6cSE1FfNBo8Ap29");
final NAME_OFFERS_ID_DEVNET = Ed25519HDPublicKey.fromBase58(
    "zugu92jR3kqgFiNEJywq7gbbc9NbaLmHLiQhsZRwd6J");
final NAME_PROGRAM_ID = Ed25519HDPublicKey.fromBase58(
    "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX");
final REVERSE_LOOKUP_CLASS = Ed25519HDPublicKey.fromBase58(
    "33m47vH6Eav6jr5Ry86XjhRft2jRBLDnDgPSHoquXi2Z");
final ROOT_DOMAIN = Ed25519HDPublicKey.fromBase58(
    "58PwtjSDuFHuUkYjH9BYnnQKHfwo9reZhC2zMJv9JPkx");
final SOL_TLD_AUTHORITY = Ed25519HDPublicKey.fromBase58(
    "58PwtjSDuFHuUkYjH9BYnnQKHfwo9reZhC2zMJv9JPkx");
final Map<SolanaEnvironment, String> urlMap = {
  SolanaEnvironment.localnet: "http://127.0.0.1:8899",
  SolanaEnvironment.devnet: "https://api.devnet.solana.com",
  SolanaEnvironment.mainnet: "https://api.mainnet-beta.solana.com",
};

enum SolanaEnvironment { localnet, devnet, mainnet }
