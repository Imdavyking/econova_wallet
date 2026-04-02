// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:alan/alan.dart' as cosmos;
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/main.dart';
import '../../interface/ft_explorer.dart';
import '../../utils/app_config.dart';
import '../cosmos_coin.dart';

/// A generic fungible token for any Cosmos-based chain.
///
/// Works for Injective (peggy denoms), Osmosis (IBC denoms),
/// Cosmos Hub, Evmos, and any other chain that uses cosmos/bank MsgSend.
///
/// Key differences from the base [CosmosCoin]:
/// - [feeDenom]     — the denom used to pay gas (e.g. 'inj', 'uosmo', 'uatom')
/// - [mintDecimals] — decimal places for this specific token
/// - [getUserBalance] filters the bank balances by [denom]
/// - [transferToken] pays fees in [feeDenom] instead of [denom]
class CosmosFungibleCoin extends CosmosCoin implements FTExplorer {
  /// Denom used to pay transaction fees on this chain.
  /// e.g. 'inj' for Injective, 'uosmo' for Osmosis, 'uatom' for Cosmos Hub
  final String feeDenom;

  /// Decimals for this specific token (may differ from the native coin).
  final int mintDecimals;

  /// Optional: the base chain's image used as the badge.
  /// If null, falls back to the parent chain lookup.
  final String? badgeImageOverride;

  factory CosmosFungibleCoin.fromParent({
    required CosmosCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String denom,
    required int mintDecimals,
  }) =>
      CosmosFungibleCoin(
        // ── inherited from parent ──────────────────────────
        blockExplorer: parent.blockExplorer,
        lcdUrl: parent.lcdUrl,
        grpcUrl: parent.grpcUrl,
        chainId: parent.chainId,
        bech32Hrp: parent.bech32Hrp,
        path: parent.path,
        grpcPort: parent.grpcPort,
        pubKeyTypeUrl: parent.pubKeyTypeUrl,
        payScheme: parent.payScheme,
        feeDenom: parent.denom, // native denom pays fees
        badgeImageOverride: parent.image,
        default_: parent.default_,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        denom: denom,
        mintDecimals: mintDecimals,
      );

  CosmosFungibleCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.bech32Hrp,
    required super.lcdUrl,
    required super.path,
    required super.denom,
    required super.grpcUrl,
    required super.chainId,
    required super.grpcPort,
    required super.pubKeyTypeUrl,
    required super.geckoID,
    required super.payScheme,
    required this.feeDenom,
    required this.mintDecimals,
    this.badgeImageOverride,
  }) : super(
          coinDecimals: mintDecimals,
          rampID: '',
        );

  // ── FTExplorer ──────────────────────────────────────────────────────────────

  @override
  String contractExplorer() {
    // Most Cosmos explorers don't have a per-token page,
    // so we fall back to the address explorer
    final replacement = '/asset/${tokenAddress()}';
    return getExplorer()
        .replaceFirst('/transaction/$blockExplorerPlaceholder', replacement)
        .replaceFirst('/transactions/$blockExplorerPlaceholder', replacement)
        .replaceFirst('/tx/$blockExplorerPlaceholder', replacement);
  }

  @override
  String savedTransKey() {
    return 'cosmosFTTransfers${denom}_$lcdUrl';
  }

  @override
  String? tokenAddress() => denom;

  @override
  String? get badgeImage {
    if (badgeImageOverride != null) return badgeImageOverride;
    // Find the parent chain by matching lcdUrl and return its image
    try {
      return getCosmosBlockChains()
          .firstWhere((c) => c.lcdUrl == lcdUrl && c.denom != denom)
          .image;
    } catch (_) {
      return null;
    }
  }

  // ── Decimals override ───────────────────────────────────────────────────────

  @override
  int decimals() => mintDecimals;

  // ── Balance: filter bank balances by this token's denom ────────────────────
  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'cosmosFTBalance${denom}_${address}_$lcdUrl';

    final storedBalance = pref.get(key);
    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final response = await get(
      Uri.parse('$lcdUrl/cosmos/bank/v1beta1/balances/$address'),
    );

    final responseBody = response.body;

    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }

    final List balances = jsonDecode(responseBody)['balances'];

    if (balances.isEmpty) return 0;

    final matching = balances.where((e) => e['denom'] == denom).toList();

    if (matching.isEmpty) return 0;

    final String rawAmount = matching[0]['amount'];
    final base = BigInt.from(10);
    return BigInt.parse(rawAmount) / base.pow(decimals());
  }

  // ── Transfer: send this token, pay fees in feeDenom ─────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final networkInfo = getNetworkInfo();
    final amountToSend = amount.toBigIntDec(decimals());

    // Fee is calculated in the native coin of the chain (feeDenom)
    // We use a fixed fee decimals lookup based on known chains
    final feeDecimals = _feeDecimalsForDenom(feeDenom);
    final feeD = await getTransactionFee(amount, to) * pow(10, feeDecimals);

    final wallet = await getWallet();

    final message = bank.MsgSend.create()
      ..fromAddress = wallet.bech32Address
      ..toAddress = to;

    // The token being transferred uses this token's denom
    final tokenCoin = cosmos.Coin.create()
      ..denom = denom
      ..amount = '$amountToSend';
    message.amount.add(tokenCoin);

    final signer = cosmos.TxSigner.fromNetworkInfo(networkInfo);

    final fee = cosmos.Fee();
    fee.gasLimit = 200000.toInt64();

    // Fee paid in the chain's native denom, not the token denom
    final feeCoin = cosmos.Coin.create()
      ..denom = feeDenom
      ..amount = BigInt.from(feeD).toString();
    fee.amount.add(feeCoin);

    final tx = await signer.createAndSign(
      wallet,
      [message],
      memo: memo,
      fee: fee,
      isEthSecp256: cosmos.Wallet.isEthSecp256(path),
      pubKeyTypeUrl: pubKeyTypeUrl,
    );

    final txBytes = tx.writeToBuffer(); // protobuf bytes

    final txSender = cosmos.TxSender.fromNetworkInfo(networkInfo);
    final response = await txSender.broadcastTx(tx);

    if (response.isSuccessful) {
      return (
        txHash: response.txhash,
        txRaw: HEX.encode(txBytes),
      );
    }
    return null;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    // Returns fee in the human-readable unit of feeDenom
    // e.g. 0.0001 INJ, 0.01 OSMO, 0.01 ATOM
    return _defaultFeeForDenom(feeDenom);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Returns the decimal places for known fee denoms.
int _feeDecimalsForDenom(String feeDenom) {
  const Map<String, int> known = {
    'inj': 18,
    'aevmos': 18,
    'uatom': 6,
    'uosmo': 6,
    'basecro': 8,
    'uxion': 6,
    'basetcro': 8,
  };
  return known[feeDenom] ?? 6;
}

/// Returns a sensible default fee (in human units) per chain.
double _defaultFeeForDenom(String feeDenom) {
  const Map<String, double> known = {
    'inj': 0.0001,
    'aevmos': 0.0001,
    'uatom': 0.01,
    'uosmo': 0.01,
    'basecro': 0.01,
    'uxion': 0.01,
    'basetcro': 0.01,
  };
  return known[feeDenom] ?? 0.01;
}

// ── Token registry ────────────────────────────────────────────────────────────

List<CosmosFungibleCoin> getCosmosFungibleCoins() {
  CosmosCoin parent(String chainId) =>
      getCosmosBlockChains().firstWhere((c) => c.chainId == chainId);

  if (enableTestNet) {
    final inj = parent('injective-888');
    return [
      CosmosFungibleCoin.fromParent(
        parent: inj,
        name: 'Tether USD (Injective Testnet)',
        symbol: 'USDT',
        image: 'assets/usdt.png',
        geckoID: 'tether',
        denom: 'peggy0x87aB3B4C8661e07D6372361211B96ed4Dc36B1B5',
        mintDecimals: 6,
      ),
    ];
  }

  final inj = parent('injective-1');
  final osmo = parent('osmosis-1');
  final evmos = parent('evmos_9001-2');

  return [
    // ── Injective ─────────────────────────────────────────────────────────
    CosmosFungibleCoin.fromParent(
      parent: inj,
      name: 'Tether USD (Injective)',
      symbol: 'USDT',
      image: 'assets/usdt.png',
      geckoID: 'tether',
      denom: 'peggy0xdAC17F958D2ee523a2206206994597C13D831ec7',
      mintDecimals: 6,
    ),
    CosmosFungibleCoin.fromParent(
      parent: inj,
      name: 'USD Coin (Injective)',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      denom: 'peggy0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      mintDecimals: 6,
    ),
    CosmosFungibleCoin.fromParent(
      parent: inj,
      name: 'Wrapped Ether (Injective)',
      symbol: 'WETH',
      image: 'assets/ethereum_logo.png',
      geckoID: 'weth',
      denom: 'peggy0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
      mintDecimals: 18,
    ),
    // ── Osmosis ───────────────────────────────────────────────────────────
    CosmosFungibleCoin.fromParent(
      parent: osmo,
      name: 'USDC (Osmosis IBC)',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      denom:
          'ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA84C',
      mintDecimals: 6,
    ),
    CosmosFungibleCoin.fromParent(
      parent: osmo,
      name: 'USDT (Osmosis IBC)',
      symbol: 'USDT',
      image: 'assets/usdt.png',
      geckoID: 'tether',
      denom:
          'ibc/4ABBEF4C8926DDDB320AE5188CFD63267ABBCEFC0583E4AE05D6E5AA2401DDAB',
      mintDecimals: 6,
    ),
    // ── Evmos ─────────────────────────────────────────────────────────────
    CosmosFungibleCoin.fromParent(
      parent: evmos,
      name: 'USDC (Evmos IBC)',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      denom:
          'ibc/7F00F3EDDD85D9C99C0A96D42C4ABF09B5FDBEFB46B09B85FF8A0A2EFC6B2F86',
      mintDecimals: 6,
    ),
  ];
}
