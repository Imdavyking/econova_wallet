// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cryptowallet/service/wallet_service.dart';
import 'package:flutter/material.dart';

import '../main.dart';

enum WalletType {
  secretPhrase,
  privateKey,
  viewKey,
}

abstract class Coin {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Coin) return false;
    final otherCoin = other;

    return otherCoin.getName() == getName() &&
        otherCoin.decimals() == decimals() &&
        otherCoin.getExplorer() == getExplorer() &&
        otherCoin.getDefault() == getDefault();
  }

  void validateAddress(String address);
  Future<String> addressExplorer();
  Map toJson();
  Future<double> getBalance(bool skipNetworkRequest);
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  });

  String getRampID();
  String getPayScheme();

  bool get supportKeystore => false;
  bool get supportPrivateKey => false;
  bool get isRpcWorking => true;
  Future<bool> needDeploy() async => false;

  Future listenForBalanceChange() async {}
  Future deployAccount() async {}
  Future<Map> getTransactions() async {
    final address = await getAddress();
    return {
      'trx': jsonDecode(pref.get(savedTransKey())),
      'currentUser': address
    };
  }

  String getGeckoId();
  bool requireMemo() => false;

  Future<double> getMaxTransfer() async {
    return await getBalance(true);
  }

  Future<String?> resolveAddress(String address) async {
    return address;
  }

  String savedTransKey() => '${getExplorer()}${getDefault()} Details';
  Future<String?> stakeToken(String amount) async {
    return null;
  }

  Future<String?> unstakeToken(String amount) async {
    return null;
  }

  Widget? getGoalPage() => null;

  Widget? getNFTPage() => null;
  Widget? getStakingPage() => null;

  int decimals();
  String getName();
  String getSymbol();
  String getExplorer();
  String getDefault();

  Future<String> getAddress() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    return details.address;
  }

  Future<bool> get canTransfer async => true;

  Future<double> getTransactionFee(String amount, String to);

  String getImage();
  String? tokenAddress() => null;

  String? get badgeImage => null;

  Future<AccountData> importData(String data) async {
    if (WalletService.isPharseKey()) {
      return fromMnemonic(mnemonic: data);
    } else if (WalletService.isViewKey()) {
      return AccountData.fromJson({
        'address': data,
      });
    } else if (WalletService.isPrivateKey()) {
      return fromPrivateKey(data);
    }
    throw Exception('invalid data type');
  }

  Future<AccountData> fromMnemonic({required String mnemonic});

  Future<AccountData> fromPrivateKey(String privateKey) async {
    throw UnimplementedError('private key derivation not implemented');
  }

  Future<double> getUserBalance({
    required String address,
  });

  @override
  int get hashCode => super.hashCode + 0;
}

class AccountData {
  final String address;
  final String? privateKey;
  final String? publicKey;
  final String? hex_address;

  AccountData({
    required this.address,
    this.privateKey,
    this.publicKey,
    this.hex_address,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'hex_address': hex_address,
    };
  }

  factory AccountData.fromJson(Map<dynamic, dynamic> json) {
    return AccountData(
      address: json['address'],
      privateKey: json['privateKey'],
      publicKey: json['publicKey'],
      hex_address: json['hex_address'],
    );
  }
}
