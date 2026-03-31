import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:convert/convert.dart';
import 'package:sha3/sha3.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:web3dart/web3dart.dart' as web3;
import '../coins/ethereum_coin.dart';
import 'abis.dart';

// ─── contract config ──────────────────────────────────────────────────────────

const _udContracts = {
  '0x049aba7510f45BA5b64ea9E658E342F904DB358D': 'Ethereum',
  '0x1BDc0fD4fbABeed3E611fd6195fCd5d41dcEF393': 'Ethereum',
  '0xa9a6A3626993D487d2Dbda3173cf58cA1a9D9e9f': 'Polygon Matic',
};

Future<Result<UDResult>> udResolver({
  required String domainName,
  String currency = 'ETH',
}) async {
  try {
    final hash = BigInt.parse(nameHash(domainName.toLowerCase().trim()));
    final key = 'crypto.$currency.address';
    final evms = getEVMBlockchains();

    final results = await Future.wait(
      _udContracts.entries.map((e) async {
        final evmDetails = evms.firstWhere(
          (c) => c.name == e.value,
          orElse: () => evms.firstWhere((c) => c.name == 'Ethereum'),
        );
        final contract = web3.DeployedContract(
          web3.ContractAbi.fromJson(json.encode(unstoppableDomainAbi), ''),
          web3.EthereumAddress.fromHex(e.key),
        );
        final client = web3.Web3Client(evmDetails.rpc, Client());
        try {
          final res = await client.call(
            contract: contract,
            function: contract.function('get'),
            params: [key, hash],
          );
          return res.first as String;
        } catch (_) {
          return '';
        }
      }),
    );

    final address = results.firstWhere((r) => r.isNotEmpty, orElse: () => '');
    if (address.isNotEmpty) return Ok(UDResult(address: address));

    return const Err('Domain not found');
  } catch (e) {
    debugPrint('udResolver: $e');
    return Err(e.toString());
  }
}

String nameHash(String? inputName) {
  String node = '';
  for (int i = 0; i < 32; i++) {
    node += '00';
  }
  if (inputName != null) {
    final labels = inputName.split('.');

    for (int i = labels.length - 1; i >= 0; i--) {
      String labelSha;
      if (_isEncodedLabelhash(labels[i])) {
        labelSha = _decodeLabelhash(labels[i]);
      } else {
        final normalisedLabel = labels[i];

        labelSha = solidityKeccak256(normalisedLabel);
      }
      node =
          solidityKeccak256(String.fromCharCodes(hex.decode('$node$labelSha')));
    }
  }

  return '0x$node';
}

bool _isEncodedLabelhash(hash) {
  return hash.startsWith('[') && hash.endsWith(']') && hash.length == 66;
}

String _decodeLabelhash(String hash) {
  if (!(hash.startsWith('[') && hash.endsWith(']'))) {
    throw 'Expected encoded labelhash to start and end with square brackets';
  }

  if (hash.length != 66) {
    throw 'Expected encoded labelhash to have a length of 66';
  }

  return hash.slice(1, -1);
}

String solidityKeccak256(String string) {
  const keccakPadding = [1, 256, 65536, 16777216];
  final hash =
      SHA3(256, keccakPadding, 256).update(string.runes.toList()).digest();

  return hex.encode(hash);
}

extension Slice on String {
  String slice(int start, [int? end]) {
    if (end != null && end.isNegative) {
      return substring(start, length - end.abs());
    }
    return substring(start, end);
  }
}
