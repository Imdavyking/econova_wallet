// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:bitbox/bitbox.dart' as bitbox;

import 'package:http/http.dart';
import 'package:cryptowallet/utils/pos_networks.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:http/http.dart' as http;

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/alt_ens.dart';
import '../utils/app_config.dart';

const sochainApi = 'https://sochain.com/api/v2/';
const bitCoinDecimals = 8;

class BitcoinCoin extends Coin {
  NetworkType POSNetwork;
  bool P2WPKH;
  String derivationPath;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;
  BitcoinCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.P2WPKH,
    required this.derivationPath,
    required this.POSNetwork,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory BitcoinCoin.fromJson(Map<String, dynamic> json) {
    return BitcoinCoin(
      POSNetwork: json['POSNetwork'],
      derivationPath: json['derivationPath'],
      P2WPKH: json['P2WPKH'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  bool get isRpcWorking => false;

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst('explorer/transactions/bch/', 'explorer/addresses/bch/')
        .replaceFirst('/transactions/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['POSNetwork'] = POSNetwork;
    data['P2WPKH'] = P2WPKH;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['derivationPath'] = derivationPath;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey =
        'bitcoinDetail$POSNetwork$default_${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = BitcoinDeriveArgs(
      seedRoot: seedPhraseRoot,
      derivationPath: derivationPath,
      P2WPKH: P2WPKH,
      POSNetwork: POSNetwork,
      default_: default_,
    );

    final keys = await compute(calculateBitCoinKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<String?> resolveAddress(String address) async {
    final resolver = await udResolver(
      domainName: address,
      currency: getDefault(),
    );

    if (resolver['success']) {
      return resolver['msg'];
    }
    return null;
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();

    final key = '${symbol}AddressBalance$address';
    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      double balance = 0.0;
      if (symbol == 'BCH') {
        final addressDetails = await bitbox.Address.details(address);
        balance = addressDetails['balance'];
      } else {
        final url = '${sochainApi}get_address_balance/$symbol/$address';
        final response = await get(Uri.parse(url));
        final data = response.body;
        balance = double.parse(jsonDecode(data)['data']['confirmed_balance']);
      }

      await pref.put(key, balance);

      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final satoshi = amount.toBigIntDec(bitCoinDecimals);

    int amountToSend = satoshi.toInt();

    return await _sendBTCType(to, amountToSend);
  }

  @override
  validateAddress(String address) {
    if (default_ == 'BCH') {
      bitbox.Address.detectFormat(address);
      return;
    }

    if (Address.validateAddress(address, POSNetwork)) {
      return;
    }

    bool canReceivePayment = false;

    try {
      final base58DecodeRecipient = bs58check.decode(address);

      final pubHashString = base58DecodeRecipient[0].toRadixString(16) +
          base58DecodeRecipient[1].toRadixString(16);

      canReceivePayment =
          hexToInt(pubHashString).toInt() == POSNetwork.pubKeyHash;
    } catch (_) {}

    if (!canReceivePayment) {
      Bech32 sel = bech32.decode(address);
      canReceivePayment = POSNetwork.bech32 == sel.hrp;
    }

    if (!canReceivePayment) {
      throw Exception('Invalid $symbol address');
    }
  }

  Future<int> _getNetworkFee(int satoshiToSend, List userUnspentInput) async {
    int inputCount = 0;
    int outputCount = 2;
    int transactionSize = 0;
    int totalAmountAvailable = 0;
    int fee = 0;

    for (int i = 0; i < userUnspentInput.length; i++) {
      transactionSize = inputCount * 146 + outputCount * 34 + 10 - inputCount;
      fee = transactionSize * 20;
      final value = userUnspentInput[i]['value'];
      double utxAvailable = double.parse(value) * pow(10, bitCoinDecimals);
      totalAmountAvailable += utxAvailable.toInt();
      inputCount += 1;
      if (totalAmountAvailable - satoshiToSend - fee >= 0) break;
    }
    return fee;
  }

  Future<List> _getUnspentTXs() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);
    final url = "${sochainApi}get_tx_unspent/$symbol/${keyPair.address}";
    final request = await http.get(Uri.parse(url));

    if (request.statusCode ~/ 100 == 4 || request.statusCode ~/ 100 == 5) {
      throw Exception('Request failed');
    }

    return jsonDecode(request.body)['data']['txs'];
  }

  Future<String> _sendBTCType(
      String destinationAddress, int satoshiToSend) async {
    if (satoshiToSend < satoshiDustAmount) {
      throw Exception('dust amount given, bitcoin too small to send');
    }
    int totalAmt = 0;
    int fee = 0;

    List userUnspentInput = await _getUnspentTXs();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);
    final sender = ECPair.fromPrivateKey(
      txDataToUintList(keyPair.privateKey!),
      network: POSNetwork,
    );

    final txb = TransactionBuilder();
    txb.setVersion(1);
    txb.network = POSNetwork;

    for (int i = 0; i < userUnspentInput.length; i++) {
      final scriptHex = userUnspentInput[i]['script_hex'];
      final txHash = userUnspentInput[i]['txid'];
      int vout = userUnspentInput[i]['output_no'];
      final value = userUnspentInput[i]['value'];
      double utxAvailable = double.parse(value) * pow(10, bitCoinDecimals);
      txb.addInput(
        txHash,
        vout,
        null,
        txDataToUintList('0x$scriptHex'),
      );

      txb.sign(
        vin: i,
        keyPair: sender,
        witnessValue: utxAvailable.toInt(),
      );
      totalAmt += utxAvailable.toInt();

      fee = await _getNetworkFee(satoshiToSend, userUnspentInput);
      if (totalAmt - satoshiToSend - fee >= 0) break;
    }

    if (totalAmt - satoshiToSend - fee < 0) {
      throw Exception('not enough fee for transfer');
    }
    final address = await getAddress();
    txb.addOutput(destinationAddress, satoshiToSend);
    txb.addOutput(address, totalAmt - satoshiToSend - fee);

    String hexBuilt = txb.build().toHex();

    final sendTransaction = await http.post(
      Uri.parse("${sochainApi}send_tx/$symbol"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'tx_hex': hexBuilt}),
    );

    if (sendTransaction.statusCode ~/ 100 == 4 ||
        sendTransaction.statusCode ~/ 100 == 5) {
      if (kDebugMode) {
        print(sendTransaction.body);
      }
      throw Exception('Request failed');
    }

    if (kDebugMode) {
      print(sendTransaction.body);
    }

    return json.decode(sendTransaction.body)['data']['txid'];
  }

  @override
  int decimals() {
    return bitCoinDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    List getUnspentOutput;
    int fee = 0;
    num satoshi = double.parse(amount) * pow(10, 8);
    int satoshiToSend = satoshi.toInt();

    getUnspentOutput = await _getUnspentTXs();
    fee = await _getNetworkFee(satoshiToSend, getUnspentOutput);

    double feeInBitcoin = fee / pow(10, bitCoinDecimals);

    return feeInBitcoin;
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<BitcoinCoin> getBitCoinPOSBlockchains() {
  List<BitcoinCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.add(
      BitcoinCoin(
        name: 'Bitcoin(Test)',
        symbol: 'BTC',
        default_: 'BTC',
        blockExplorer:
            'https://www.blockchain.com/btc-testnet/tx/$blockExplorerPlaceholder',
        image: 'assets/bitcoin.jpg',
        POSNetwork: testnet,
        P2WPKH: false,
        derivationPath: "m/44'/0'/0'/0/0",
        geckoID: "bitcoin",
        rampID: 'BTC_BTC',
        payScheme: 'bitcoin',
      ),
    );
  } else {
    blockChains.addAll([
      BitcoinCoin(
        name: 'Bitcoin',
        symbol: 'BTC',
        default_: 'BTC',
        blockExplorer:
            'https://live.blockcypher.com/btc/tx/$blockExplorerPlaceholder',
        image: 'assets/bitcoin.jpg',
        POSNetwork: bitcoin,
        P2WPKH: true,
        derivationPath: "m/84'/0'/0'/0/0",
        geckoID: "bitcoin",
        rampID: 'BTC_BTC',
        payScheme: 'bitcoin',
      ),
      BitcoinCoin(
        symbol: 'BCH',
        name: 'BitcoinCash',
        default_: 'BCH',
        blockExplorer:
            'https://www.blockchain.com/explorer/transactions/bch/$blockExplorerPlaceholder',
        image: 'assets/bitcoin_cash.png',
        POSNetwork: bitcoincash,
        P2WPKH: false,
        derivationPath: "m/44'/145'/0'/0/0",
        geckoID: 'bitcoin-cash',
        rampID: 'BCH_BCH',
        payScheme: 'bitcoincash',
      ),
      BitcoinCoin(
        name: 'Litecoin',
        symbol: 'LTC',
        default_: 'LTC',
        blockExplorer:
            'https://live.blockcypher.com/ltc/tx/$blockExplorerPlaceholder',
        image: 'assets/litecoin.png',
        POSNetwork: litecoin,
        P2WPKH: true,
        derivationPath: "m/84'/2'/0'/0/0",
        geckoID: "litecoin",
        rampID: 'LTC_LTC',
        payScheme: 'litecoin',
      ),
      BitcoinCoin(
        name: 'Dash',
        symbol: 'DASH',
        default_: 'DASH',
        blockExplorer:
            'https://live.blockcypher.com/dash/tx/$blockExplorerPlaceholder',
        image: 'assets/dash.png',
        POSNetwork: dash,
        P2WPKH: false,
        derivationPath: "m/44'/5'/0'/0/0",
        geckoID: 'dash',
        rampID: '',
        payScheme: 'dash',
      ),
      BitcoinCoin(
        name: 'ZCash',
        symbol: 'ZEC',
        default_: 'ZEC',
        blockExplorer:
            'https://zcashblockexplorer.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/zcash.png',
        POSNetwork: zcash,
        P2WPKH: false,
        derivationPath: "m/44'/133'/0'/0/0",
        geckoID: 'zcash',
        rampID: '',
        payScheme: 'zcash',
      ),
      BitcoinCoin(
        name: 'Dogecoin',
        symbol: 'DOGE',
        default_: 'DOGE',
        blockExplorer:
            'https://live.blockcypher.com/doge/tx/$blockExplorerPlaceholder',
        image: 'assets/dogecoin.png',
        POSNetwork: dogecoin,
        P2WPKH: false,
        derivationPath: "m/44'/3'/0'/0/0",
        geckoID: "dogecoin",
        rampID: 'DOGE_DOGE',
        payScheme: 'doge',
      ),
    ]);
  }

  return blockChains;
}

class BitcoinDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final bool P2WPKH;
  final NetworkType POSNetwork;
  final String default_;

  const BitcoinDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.P2WPKH,
    required this.POSNetwork,
    required this.default_,
  });
}

Map calculateBitCoinKey(BitcoinDeriveArgs config) {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final node = seedRoot_.root.derivePath(config.derivationPath);

  String address;
  if (config.P2WPKH) {
    address = P2WPKH(
      data: PaymentData(
        pubkey: node.publicKey,
      ),
      network: config.POSNetwork,
    ).data.address!;
  } else {
    address = P2PKH(
      data: PaymentData(
        pubkey: node.publicKey,
      ),
      network: config.POSNetwork,
    ).data.address!;
  }
  if (config.default_ == 'BCH') {
    if (bitbox.Address.detectFormat(address) == bitbox.Address.formatLegacy) {
      address = bitbox.Address.toCashAddress(address).split(':')[1];
    }
  }

  if (config.default_ == 'ZEC') {
    final baddr = [...bs58check.decode(address)];
    baddr.removeAt(0);

    final taddr = Uint8List(22);

    taddr.setAll(2, baddr);
    taddr.setAll(0, [0x1c, 0xb8]);

    address = bs58check.encode(taddr);
  }

  return {
    'address': address,
    'privateKey': "0x${HEX.encode(node.privateKey!)}"
  };
}
