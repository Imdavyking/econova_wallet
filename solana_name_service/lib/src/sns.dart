import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

import 'borsh/borsh_extensions.dart';
import 'classes/dtos.dart';
import 'constants.dart';
import 'pda.dart';

Future<String?> fetchSolanaNameServiceName(String publicKey,
    {SolanaEnvironment environment = SolanaEnvironment.mainnet}) async {
  try {
    if (publicKey.isNotEmpty) {
      final address = Ed25519HDPublicKey.fromBase58(publicKey);
      var domainName =
          await findFavoriteDomainName(address, environment: environment);
      if (domainName?.isNotEmpty != true) {
        final domainKeys = await findOwnedNameAccountsForUser(address,
            environment: environment);
        domainKeys.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
        for (var domainKey in domainKeys) {
          domainName =
              await performReverseLookup(domainKey, environment: environment);
          if (domainName != null) {
            return domainName;
          }
        }
      }
      return domainName;
    }
  } catch (e) {
    print(e);
  }
  return null;
}

Future<Ed25519HDPublicKey?> findAccountByName(String name,
    {SolanaEnvironment environment = SolanaEnvironment.mainnet}) async {
  try {
    final hashedName = getHashedName(name);
    final key = await getNameAccountKey(hashedName, null, SOL_TLD_AUTHORITY);
    final registryAccount = await RpcClient(urlMap[environment]!)
        .getAccountInfo(key.toBase58(), encoding: Encoding.base64);
    if (registryAccount.value?.data == null) return null;
    final registry = parseBytesFromAccount(
        registryAccount.value, NameRegistryState.fromBorsh,
        skip: 0);
    return registry.owner;
  } catch (e) {
    // TODO: investigate occasional buffer overflow error
    return null;
  }
}

Future<String?> findFavoriteDomainName(Ed25519HDPublicKey owner,
    {SolanaEnvironment environment = SolanaEnvironment.mainnet}) async {
  try {
    final url = urlMap[environment]!;
    final client = RpcClient(url);
    final favoriteKey =
        await getBonfidaSNSProgramAddress(NAME_OFFERS_ID, owner);
    final favoriteAccount = await client.getAccountInfo(favoriteKey.toBase58(),
        encoding: Encoding.base64);
    if (favoriteAccount.value?.data == null) {
      return null;
    }
    final favoriteDomain = parseBytesFromAccount(
        favoriteAccount.value, FavoriteDomain.fromBorsh,
        skip: 0);

    return await performReverseLookup(favoriteDomain.nameAccount,
        environment: environment);
  } catch (e) {
    print(e);
  }
  return null;
}

Future<List<Ed25519HDPublicKey>> findOwnedNameAccountsForUser(
    Ed25519HDPublicKey userAccount,
    {SolanaEnvironment environment = SolanaEnvironment.mainnet}) async {
  final List<ProgramDataFilter> filters = [
    ProgramDataFilter.memcmp(offset: 32, bytes: userAccount.bytes)
  ];
  final accounts = await RpcClient(urlMap[environment]!).getProgramAccounts(
      NAME_PROGRAM_ID.toBase58(),
      encoding: Encoding.base64,
      filters: filters);
  return accounts.map((e) => Ed25519HDPublicKey.fromBase58(e.pubkey)).toList();
}

Uint8List getHashedName(String name) {
  final input = HASH_PREFIX + name;
  final encodedStr = utf8.encode(input);
  final convertedStr = sha256.convert(encodedStr);
  return Uint8List.fromList(convertedStr.bytes);
}

Future<Ed25519HDPublicKey> getNameAccountKey(Uint8List hashedName,
    Ed25519HDPublicKey? nameClass, Ed25519HDPublicKey? nameParent) {
  var seeds = [hashedName];
  if (nameClass != null) {
    seeds.add(Uint8List.fromList(nameClass.bytes));
  } else {
    seeds.add(Uint8List(32));
  }
  if (nameParent != null) {
    seeds.add(Uint8List.fromList(nameParent.bytes));
  } else {
    seeds.add(Uint8List(32));
  }
  return Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds, programId: NAME_PROGRAM_ID);
}

Future<String?> performReverseLookup(Ed25519HDPublicKey nameAccount,
    {SolanaEnvironment environment = SolanaEnvironment.mainnet}) async {
  final hashedReverseLookup = getHashedName(nameAccount.toBase58());
  final reverseLookupAccount =
      await getNameAccountKey(hashedReverseLookup, REVERSE_LOOKUP_CLASS, null);

  final registryAccount = await RpcClient(urlMap[environment]!).getAccountInfo(
      reverseLookupAccount.toBase58(),
      encoding: Encoding.base64);
  if (registryAccount.value?.data == null) return null;
  final registry = parseBytesFromAccount(
      registryAccount.value, NameRegistryState.fromBorsh,
      skip: 0);
  return registry.name;
}
