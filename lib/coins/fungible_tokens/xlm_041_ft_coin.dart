// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;
import 'package:wallet_app/coins/stellar_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'dart:convert';
import 'package:wallet_app/utils/app_config.dart';

class StellarSep041Coin extends StellarCoin implements FTExplorer {
  final String contractId;
  final int mintDecimals;
  final String _geckoID;

  late final stellar.SorobanServer _soroban;

  StellarSep041Coin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.sdk,
    required super.cluster,
    required super.caipReference,
    required this.contractId,
    required this.mintDecimals,
    String geckoID = '',
  })  : _geckoID = geckoID,
        super(rampID: '', payScheme: '', geckoID: geckoID) {
    _soroban = stellar.SorobanServer(
      cluster == stellar.Network.TESTNET
          ? 'https://soroban-testnet.stellar.org'
          : 'https://soroban.stellar.org',
    );
  }

  factory StellarSep041Coin.fromParent({
    required StellarCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String contractId,
    required int mintDecimals,
    String geckoID = '',
    String? blockExplorerOverride,
  }) =>
      StellarSep041Coin(
        blockExplorer: blockExplorerOverride ?? parent.blockExplorer,
        sdk: parent.sdk,
        cluster: parent.cluster,
        caipReference: parent.caipReference,
        default_: parent.default_,
        name: name,
        symbol: symbol,
        image: image,
        contractId: contractId,
        mintDecimals: mintDecimals,
        geckoID: geckoID,
      );

  factory StellarSep041Coin.fromJson(Map<String, dynamic> json) =>
      StellarSep041Coin(
        sdk: json['sdk'],
        cluster: json['cluster'],
        blockExplorer: json['blockExplorer'],
        default_: json['default'],
        symbol: json['symbol'],
        image: json['image'],
        name: json['name'],
        caipReference: json['caipReference'],
        contractId: json['contractId'],
        mintDecimals: json['mintDecimals'],
        geckoID: json['geckoID'] ?? '',
      );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['contractId'] = contractId;
    data['mintDecimals'] = mintDecimals;
    return data;
  }

  // ── FTExplorer ─────────────────────────────────────────────────────────────

  @override
  String? tokenAddress() => contractId;

  @override
  String savedTransKey() => 'sep041Transfers$contractId';

  @override
  int decimals() => mintDecimals;

  @override
  Widget? getNFTPage() => null;

  @override
  String contractExplorer() {
    return getExplorer()
        .replaceFirst('/transactions/', '/accounts/')
        .replaceFirst(blockExplorerPlaceholder, contractId);
  }

  @override
  String? get badgeImage => getStellarBlockChains().first.image;

  @override
  String getGeckoId() => _geckoID;

  // ── Soroban helpers ────────────────────────────────────────────────────────

  /// Address SCVal — correct API: Address.forAccountId().toXdrSCVal()
  stellar.XdrSCVal _accountAddressVal(String accountId) {
    return stellar.Address.forAccountId(accountId).toXdrSCVal();
  }

  /// i128 SCVal from a human-readable amount string
  stellar.XdrSCVal _toI128Val(String amount) {
    final units = (double.parse(amount) * _pow10(mintDecimals)).round();
    final big = BigInt.from(units).toSigned(128);
    final hi = (big >> 64).toSigned(64).toInt();
    final lo =
        (big & BigInt.parse('0xFFFFFFFFFFFFFFFF')).toUnsigned(64).toInt();
    return stellar.XdrSCVal.forI128Parts(hi, lo);
  }

  /// Decode i128 SCVal → double
  double _i128ToDouble(stellar.XdrSCVal val) {
    final raw = val.i128;
    if (raw == null) return 0;
    final big = (BigInt.from(raw.hi.int64) << 64) | BigInt.from(raw.lo.uint64);
    return big / BigInt.from(_pow10(mintDecimals));
  }

  int _pow10(int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  /// Builds InvokeContractHostFunction — takes contractId string directly
  stellar.InvokeHostFuncOpBuilder _buildInvokeOp({
    required String functionName,
    required List<stellar.XdrSCVal> args,
  }) {
    final hostFn = stellar.InvokeContractHostFunction(
      contractId,
      functionName,
      arguments: args,
    );
    return stellar.InvokeHostFuncOpBuilder(hostFn);
  }

  Uint8List _decodeXdrBytes(String xdr) {
    // Base64 strings only contain A-Z, a-z, 0-9, +, /, =
    // Hex strings only contain 0-9, a-f, A-F
    final isHex = RegExp(r'^[0-9a-fA-F]+$').hasMatch(xdr);

    return isHex ? stellar.Util.hexToBytes(xdr) : base64Decode(xdr);
  }

  /// Simulate a read-only call and return the result SCVal
  Future<stellar.XdrSCVal> _simulateQuery({
    required String functionName,
    required List<stellar.XdrSCVal> args,
    required String callerAddress,
  }) async {
    final account = await sdk.accounts.account(callerAddress);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _buildInvokeOp(functionName: functionName, args: args).build(),
        )
        .build();

    final request = stellar.SimulateTransactionRequest(tx);
    final simResponse = await _soroban.simulateTransaction(request);

    if (simResponse.error != null) {
      throw Exception(
          'Soroban sim error [$functionName]: ${simResponse.error}');
    }

    final resultXdr = simResponse.results?.first.xdr;
    if (resultXdr == null) {
      throw Exception('No result from contract call: $functionName');
    }

    return stellar.XdrSCVal.decode(
      stellar.XdrDataInputStream(_decodeXdrBytes(resultXdr)),
    );
  }

  // ── Balance ────────────────────────────────────────────────────────────────

  Future<double> _contractBalance(String address) async {
    final result = await _simulateQuery(
      functionName: 'balance',
      args: [_accountAddressVal(address)],
      callerAddress: address,
    );

    return _i128ToDouble(result);
  }

  @override
  Future<double> getUserBalance({required String address}) =>
      _contractBalance(address);

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'sep041Balance$address$contractId';
    double saved = pref.get(key) ?? 0;

    if (useCache) return saved;

    try {
      final balance = await _contractBalance(address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      debugPrint('sep041 getBalance error: $e');
      return saved;
    }
  }

  // ── Transfer ───────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final stellarDetails = await importData(data);
    final keyPair = stellar.KeyPair.fromSecretSeed(stellarDetails.privateKey!);

    final account = await sdk.accounts.account(keyPair.accountId);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _buildInvokeOp(
            functionName: 'transfer',
            args: [
              _accountAddressVal(keyPair.accountId), // from
              _accountAddressVal(to), // to
              _toI128Val(amount), // amount i128
            ],
          ).build(),
        )
        .build();

    // ── Simulate + prepare (sets footprint, auth, fee) ─────────────────────
    // prepareTransaction() does simulate + assemble in one call
    stellar.Transaction preparedTx;
    // ── Simulate + prepare (sets footprint, auth, fee) ─────────────────────
    try {
      final simRequest = stellar.SimulateTransactionRequest(tx);
      final simResponse = await _soroban.simulateTransaction(simRequest);

      if (simResponse.error != null) {
        throw Exception('SEP-041 simulate failed: ${simResponse.error}');
      }

      // Attach Soroban resource data + resource fee (the "prepare" step)
      tx.sorobanTransactionData = simResponse.transactionData;
      tx.addResourceFee(simResponse.minResourceFee!);

      // If the contract requires auth entries, attach them too
      final authEntries = simResponse.sorobanAuth;
      if (authEntries != null && authEntries.isNotEmpty) {
        tx.setSorobanAuth(authEntries);
      }

      preparedTx = tx;
    } catch (e) {
      throw Exception('SEP-041 prepare failed: $e');
    }

    // ── Sign ───────────────────────────────────────────────────────────────
    preparedTx.sign(keyPair, cluster);
    final txRaw = preparedTx.toEnvelopeXdrBase64();

    // ── Submit ─────────────────────────────────────────────────────────────
    final sendResponse = await _soroban.sendTransaction(preparedTx);
    if (sendResponse.error != null) {
      throw Exception('SEP-041 send failed: ${sendResponse.error?.message}');
    }

    final hash = sendResponse.hash!;

    // ── Poll for finality ──────────────────────────────────────────────────
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final getResp = await _soroban.getTransaction(hash);

      if (getResp.status == stellar.GetTransactionResponse.STATUS_SUCCESS) {
        return (txHash: hash, txRaw: txRaw);
      }
      if (getResp.status == stellar.GetTransactionResponse.STATUS_FAILED) {
        throw Exception('SEP-041 transfer failed on-chain.');
      }
    }

    throw Exception('SEP-041 transfer timed out.');
  }
}

// ── Registry ──────────────────────────────────────────────────────────────────

List<StellarSep041Coin> getStellarSep041Coins() {
  final parent = getStellarBlockChains().first;

  if (enableTestNet) {
    return [
      StellarSep041Coin.fromParent(
        parent: parent,
        name: 'USDC (SEP-041 Testnet)',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        // SAC address for USDC:GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5
        contractId: 'CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA',
        mintDecimals: 7,
        geckoID: 'usd-coin',
      ),
    ];
  }

  return [
    StellarSep041Coin.fromParent(
      parent: parent,
      name: 'USDC (SEP-041)',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      // Run: stellar contract id asset --asset USDC:GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN --network mainnet
      contractId: 'CCW67TSZV3SSS2HXMBQ5JFGCKJNXKZM7UQUWUZPUTHXSTZLEO7SJMI75',
      mintDecimals: 7,
      geckoID: 'usd-coin',
    ),
  ];
}
