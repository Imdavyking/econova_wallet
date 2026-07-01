export interface ZkProofInput {
  // 🕵️ Private witnesses
  issuer: `0x${string}`;          // Field as hex
  issued_at: `0x${string}`;       // u64 as hex
  valid_until: `0x${string}`;     // u64 as hex
  is_valid: boolean;              // bool
  secret: `0x${string}`;          // Field as hex
  year_of_birth: number;          // u16

  // 🌍 Public inputs
  hash: `0x${string}`;            // Field as hex
  min_age_feature: number;        // u16
  access_nullifier: `0x${string}`; // Field as hex
  now: `0x${string}`;             // u64 as hex
  owner: `0x${string}`;           // Field as hex
  current_year: number;           // u16
}
