// src/lib/actions.ts

import {
  Contract,
  TransactionBuilder,
  rpc as StellarRpc,
  Address,
  nativeToScVal,
  scValToNative,
  xdr,
  StrKey,
} from "@stellar/stellar-sdk";

export const FIELD_MODULUS = BigInt(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617",
);
export function addressToFieldHex(stellarAddress: string): string {
  const pubKeyBytes = StrKey.decodeEd25519PublicKey(stellarAddress);
  let asBigInt = BigInt("0x" + bytesToHex(pubKeyBytes));
  asBigInt = asBigInt % FIELD_MODULUS;
  return "0x" + asBigInt.toString(16);
}

export function bytesToHex(bytes: Uint8Array | Buffer | number[]): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
