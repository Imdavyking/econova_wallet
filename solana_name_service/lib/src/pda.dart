import 'dart:convert';

import 'package:solana/solana.dart';

import 'constants.dart';

Future<Ed25519HDPublicKey> getBonfidaSNSProgramAddress(
    Ed25519HDPublicKey programId, Ed25519HDPublicKey owner) {
  return Ed25519HDPublicKey.findProgramAddress(seeds: [
    utf8.encode(FAVORITE_DOMAIN_SEED),
    owner.bytes,
  ], programId: programId);
}
