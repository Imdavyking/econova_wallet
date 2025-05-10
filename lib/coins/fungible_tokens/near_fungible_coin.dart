import 'dart:convert';

import 'package:cryptowallet/coins/near_coin.dart';
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
    required String api,
    required String blockExplorer,
    required String symbol,
    required String default_,
    required String image,
    required String name,
    required String suffix,
    required String geckoID,
    required this.mintDecimals,
    required this.contractID,
  }) : super(
          api: api,
          geckoID: geckoID,
          blockExplorer: blockExplorer,
          symbol: symbol,
          default_: default_,
          image: image,
          name: name,
          suffix: suffix,
          rampID: '',
          payScheme: '',
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
  String get badgeImage => nearChains.first.image;

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
  Future<String?> transferToken(String amount, String to,
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
      return entry['transaction']['hash'];
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
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'nearAddressBalance$address$api$contractID';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final account = await getAccount();

      String method = 'ft_balance_of';
      String args = json.encode(
        {
          'account_id': account.accountId,
        },
      );

      Contract contract = Contract(contractID, account);

      var result = await contract.callViewFuntion(method, args);

      if (result['result'] == null) return savedBalance;

      List<int> blRst = List<int>.from(result['result']['result']);

      blRst.removeWhere((int num) => num == asciiQuote || num == asciiDobQuote);

      final toknBal = BigInt.parse(ascii.decode(blRst));

      final base = BigInt.from(10);

      final tknBal = toknBal / base.pow(decimals());
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

List<NearFungibleCoin> walletNearCoin() {
  List<NearFungibleCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(NearFungibleCoin(
      name: 'PRIME (Testnet)',
      symbol: 'PRM',
      default_: 'NEAR',
      blockExplorer:
          'https://testnet.nearblocks.io/txns/$blockExplorerPlaceholder',
      image: 'assets/logo.png',
      api: 'https://rpc.testnet.near.org',
      contractID: 'primewallet.testnet',
      suffix: '.testnet',
      mintDecimals: 9,
      geckoID: '',
    ));
  } else {
    blockChains.addAll([
      NearFungibleCoin(
        name: 'PRIME',
        symbol: 'PRM',
        default_: 'NEAR',
        blockExplorer: 'https://nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/logo.png',
        api: 'https://rpc.mainnet.near.org',
        contractID: 'primewallet.near',
        suffix: '.near',
        mintDecimals: 9,
        geckoID: '',
      ),
    ]);
  }

  return blockChains;
}

List<NearFungibleCoin> getNearFungibles() {
  List<NearFungibleCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll(
      [
        NearFungibleCoin(
          name: 'USDC (Testnet)',
          symbol: 'USDC',
          default_: 'NEAR',
          blockExplorer:
              'https://testnet.nearblocks.io/txns/$blockExplorerPlaceholder',
          image: 'assets/wusd.png',
          api: 'https://rpc.testnet.near.org',
          contractID:
              '3e2210e1184b45b64c8a434c0a7e7b23cc04ea7eb7a6c3c32520d03d4afcb8af',
          suffix: '.testnet',
          mintDecimals: 6,
          geckoID: 'usd-coin',
        ),
      ],
    );
  } else {
    blockChains.addAll([
      NearFungibleCoin(
        name: 'USDC',
        symbol: 'USDC',
        default_: 'NEAR',
        blockExplorer: 'https://nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/wusd.png',
        api: 'https://rpc.mainnet.near.org',
        contractID:
            '17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1',
        suffix: '.near',
        mintDecimals: 6,
        geckoID: 'usd-coin',
      ),
      NearFungibleCoin(
        name: 'Tether USD',
        symbol: 'USDT',
        default_: 'NEAR',
        blockExplorer: 'https://nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/usdt.png',
        api: 'https://rpc.mainnet.near.org',
        contractID: 'usdt.tether-token.near',
        suffix: '.near',
        mintDecimals: 6,
        geckoID: 'tether',
      ),
      NearFungibleCoin(
        name: 'SWEAT',
        symbol: 'SWEAT',
        default_: 'NEAR',
        blockExplorer: 'https://nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/sweat.png',
        api: 'https://rpc.mainnet.near.org',
        contractID: 'token.sweat',
        suffix: '.near',
        mintDecimals: 18,
        geckoID: 'sweatcoin',
      ),
    ]);
  }

  blockChains.addAll(walletNearCoin());
  return blockChains;
}
