import 'dart:convert';

import 'package:wallet_app/coins/near_coin.dart';
import 'package:flutter/foundation.dart';
import 'package:near_api_flutter/near_api_flutter.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../main.dart';
import '../../utils/app_config.dart';

int asciiQuote = 39;
int asciiDobQuote = 34;

class NearFungibleCoin extends NearCoin implements FTExplorer {
  String contractID;
  int mintDecimals;

  NearFungibleCoin({
    required super.api,
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.suffix,
    required super.geckoID,
    required super.caipReference,
    required this.mintDecimals,
    required this.contractID,
  }) : super(
          rampID: '',
          payScheme: '',
        );

  /// Inherits all network config from [parent] — only pass token-specific fields.
  factory NearFungibleCoin.fromParent({
    required NearCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String contractID,
    required int mintDecimals,
  }) =>
      NearFungibleCoin(
        // ── inherited from parent ──────────────────────────
        api: parent.api,
        blockExplorer: parent.blockExplorer,
        suffix: parent.suffix,
        caipReference: parent.caipReference,
        default_: parent.default_,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        contractID: contractID,
        mintDecimals: mintDecimals,
      );

  factory NearFungibleCoin.fromJson(Map<String, dynamic> json) {
    return NearFungibleCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      suffix: json['suffix'],
      contractID: json['contractID'],
      mintDecimals: json['mintDecimals'],
      geckoID: json['geckoID'],
      caipReference: json['caipReference'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['suffix'] = suffix;
    data['contractID'] = contractID;
    data['mintDecimals'] = mintDecimals;

    return data;
  }

  @override
  String? get badgeImage => getNearBlockChains().first.image;

  @override
  int decimals() => mintDecimals;

  @override
  String tokenAddress() => contractID;

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/txns/$blockExplorerPlaceholder',
      '/token/${tokenAddress()}',
    );
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final account = await getAccount();

    if (!await _haveRegistered(accountID: to)) {
      await _registerToken(accountID: to);
      await Future.delayed(const Duration(seconds: 2));
    }

    String method = 'ft_transfer';
    final tknAmt = amount.toBigIntDec(decimals());

    String args = json.encode(
      {
        'receiver_id': to,
        'amount': tknAmt.toString(),
      },
    );

    Contract contract = Contract(contractID, account);

    Map? result = await contract.callFunction(method, args, BigInt.parse('1'));
    final entry = result['result'];

    if (entry == null) {
      return null;
    }

    if (entry['final_execution_status'] == 'EXECUTED_OPTIMISTIC') {
      return (
        txHash: entry['transaction']['hash'] as String,
        txRaw: null,
      );
    }

    return null;
  }

  @override
  String savedTransKey() => '$contractID$api NearFtDetails';

  Future<bool> _registerToken({required String accountID}) async {
    try {
      final account = await getAccount();
      String method = 'storage_deposit';
      String args = json.encode(
        {
          'account_id': accountID,
        },
      );

      Contract contract = Contract(contractID, account);

      await contract.callFunction(
        method,
        args,
        BigInt.parse('1250000000000000000000'),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _haveRegistered({required String accountID}) async {
    try {
      final account = await getAccount();
      String method = 'storage_balance_of';
      String args = json.encode(
        {
          'account_id': accountID,
        },
      );

      Contract contract = Contract(contractID, account);
      Map<dynamic, dynamic> result =
          await contract.callViewFuntion(method, args);

      if (result['result'] == null) return false;

      List<int> blRst = List<int>.from(result['result']['result']);

      if (ascii.decode(blRst) == 'null') {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final account = await getAccount();

    String method = 'ft_balance_of';
    String args = json.encode(
      {
        'account_id': account.accountId,
      },
    );

    Contract contract = Contract(contractID, account);

    var result = await contract.callViewFuntion(method, args);

    if (result['result'] == null) return 0;

    List<int> blRst = List<int>.from(result['result']['result']);

    blRst.removeWhere((int num) => num == asciiQuote || num == asciiDobQuote);

    final toknBal = BigInt.parse(ascii.decode(blRst));

    final base = BigInt.from(10);

    return toknBal / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'nearAddressBalance$address$api$contractID';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final tknBal = await getUserBalance(address: address);
      await pref.put(key, tknBal);

      return tknBal;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return savedBalance;
    }
  }

  @override
  String getGeckoId() => geckoID;
}

List<NearFungibleCoin> getNearFungibles() {
  final parent = getNearBlockChains().first;

  final List<NearFungibleCoin> blockChains;

  if (enableTestNet) {
    blockChains = [
      NearFungibleCoin.fromParent(
        parent: parent,
        name: 'USDC (Testnet)',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        contractID:
            '3e2210e1184b45b64c8a434c0a7e7b23cc04ea7eb7a6c3c32520d03d4afcb8af',
        mintDecimals: 6,
      ),
    ];
  } else {
    blockChains = [
      NearFungibleCoin.fromParent(
        parent: parent,
        name: 'USDC',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        contractID:
            '17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1',
        mintDecimals: 6,
      ),
      NearFungibleCoin.fromParent(
        parent: parent,
        name: 'Tether USD',
        symbol: 'USDT',
        image: 'assets/usdt.png',
        geckoID: 'tether',
        contractID: 'usdt.tether-token.near',
        mintDecimals: 6,
      ),
      NearFungibleCoin.fromParent(
        parent: parent,
        name: 'SWEAT',
        symbol: 'SWEAT',
        image: 'assets/sweat.png',
        geckoID: 'sweatcoin',
        contractID: 'token.sweat',
        mintDecimals: 18,
      ),
    ];
  }

  return blockChains;
}
