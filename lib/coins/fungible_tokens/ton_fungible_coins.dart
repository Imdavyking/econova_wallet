// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:hex/hex.dart';
import 'package:ton_dart/ton_dart.dart';
import '../../interface/ft_explorer.dart';
import '../../main.dart';
import '../../service/wallet_service.dart';
import '../../utils/app_config.dart';
import '../ton_coin.dart';

class TonFungibleCoin extends TonCoin implements FTExplorer {
  String tokenID;

  int mintDecimals;

  TonFungibleCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.api,
    required super.caipReference,
    required this.mintDecimals,
    required this.tokenID,
    required super.geckoID,
  }) : super(
          rampID: '',
          payScheme: '',
        );

  /// Inherits all network config from [parent] — only pass token-specific fields.
  factory TonFungibleCoin.fromParent({
    required TonCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String tokenID,
    required int mintDecimals,
  }) =>
      TonFungibleCoin(
        // ── inherited from parent ──────────────────────────
        blockExplorer: parent.blockExplorer,
        api: parent.api,
        caipReference: parent.caipReference,
        default_: parent.default_,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        tokenID: tokenID,
        mintDecimals: mintDecimals,
      );

  factory TonFungibleCoin.fromJson(Map<String, dynamic> json) {
    return TonFungibleCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      mintDecimals: json['mintDecimals'],
      tokenID: json['tokenID'],
      geckoID: json['geckoID'],
      caipReference: json['caipReference'],
    );
  }

  @override
  String? get badgeImage => getChains<TonCoin>().first.image;

  @override
  String savedTransKey() => '$tokenID$api FTDetails';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['mintDecimals'] = mintDecimals;
    data['tokenID'] = tokenID;
    data['geckoID'] = geckoID;
    return data;
  }

  @override
  int decimals() => mintDecimals;

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/tx/$blockExplorerPlaceholder',
      '/jetton/${tokenAddress()}',
    );
  }

  @override
  String tokenAddress() => tokenID;

  @override
  Future<double> getUserBalance({required String address}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    final ownerWallet = WalletV4.create(
      chain: TonChain.fromWorkchain(0),
      publicKey: HEX.decode(details.publicKey!),
      bounceableAddress: true,
    );

    final minter = JettonMinter(
      owner: ownerWallet,
      address: TonAddress(
        tokenID,
      ),
    );

    final jettonWalletAddress = await minter.getWalletAddress(
      rpc: getRpc(),
      owner: ownerWallet.address,
    );

    final jettonWallet = await JettonWallet.fromAddress(
      address: jettonWalletAddress,
      owner: ownerWallet,
      rpc: getRpc(),
    );

    final balance = await jettonWallet.getBalance(getRpc());
    return balance / BigInt.from(10).pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    final address = details.address;
    final key = 'tonFTAddressBalance$api$address$tokenID';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double balTon = await getUserBalance(address: address);
      await pref.put(key, balTon);
      return balTon;
    } catch (_) {
      return savedBalance;
    }
  }

  // ignore: unused_element
  _mintTokens() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tonDetails = await importData(data);
    final privateKey = TonPrivateKey.fromBytes(
      HEX.decode(tonDetails.privateKey!),
    );
    final ownerWallet = WalletV4.create(
      chain: TonChain.fromWorkchain(0),
      publicKey: HEX.decode(tonDetails.publicKey!),
      bounceableAddress: true,
    );

    final minter = JettonMinter.create(
      owner: ownerWallet,
      state: MinterWalletState(
        owner: ownerWallet.address,
        chain: TonChain.testnet,
        metadata: JettonOnChainMetadata.snakeFormat(
          name: walletName,
          symbol: walletAbbr,
          decimals: 9,
        ),
      ),
    );

    final addressToMint = TonAddress(
      tonDetails.address,
      forceWorkchain: 0,
    );

    final amount = TonHelper.toNano("0.5");
    final forwardAmount = TonHelper.toNano("0.3");
    final totalAmount = TonHelper.toNano("0.4");
    final jettonAmountForMint = BigInt.parse("1${"0" * 15}");

    await minter.sendOperation(
      signerParams: VersionedTransferParams(privateKey: privateKey),
      rpc: getRpc(),
      amount: amount + totalAmount,
      operation: JettonMinterMint(
        totalTonAmount: totalAmount,
        to: addressToMint,
        transfer: JettonMinterInternalTransfer(
          jettonAmount: jettonAmountForMint,
          forwardTonAmount: forwardAmount,
        ),
        jettonAmount: jettonAmountForMint,
      ),
    );
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tonDetails = await importData(data);
    final ownerWallet = WalletV4.create(
      chain: TonChain.fromWorkchain(0),
      publicKey: HEX.decode(tonDetails.publicKey!),
      bounceableAddress: true,
    );

    final minter = JettonMinter(
      owner: ownerWallet,
      address: TonAddress(
        tokenID,
      ),
    );

    final jettonWalletAddress = await minter.getWalletAddress(
      rpc: getRpc(),
      owner: ownerWallet.address,
    );

    final jettonWallet = await JettonWallet.fromAddress(
      address: jettonWalletAddress,
      owner: ownerWallet,
      rpc: getRpc(),
    );

    final forwardTonAmount = TonHelper.toNano("0.1");
    final transferAmount = amount.toBigIntDec(decimals());
    final BigInt feeAmount = TonHelper.toNano("0.3");
    final privateKey = TonPrivateKey.fromBytes(
      HEX.decode(tonDetails.privateKey!),
    );

    final tx = await jettonWallet.sendOperation(
      signerParams: VersionedTransferParams(privateKey: privateKey),
      rpc: getRpc(),
      amount: feeAmount + forwardTonAmount,
      operation: JettonWalletTransfer(
        amount: transferAmount,
        destination: TonAddress(to),
        forwardTonAmount: forwardTonAmount,
        forwardPayload: memo == null ? null : buildMessageBody(memo),
      ),
    );

    return (
      txHash: tx,
      txRaw: null,
    );
  }

  Cell buildMessageBody(String? memo) {
    if (memo != null) {
      return beginCell().storeUint(0, 32).storeStringTail(memo).endCell();
    }
    return Cell.empty;
  }

  @override
  String getGeckoId() => geckoID;
}

List<TonFungibleCoin> getTonFungibleCoins() {
  final parent = getChains<TonCoin>().first;

  if (enableTestNet) {
    return [
      TonFungibleCoin.fromParent(
        parent: parent,
        name: 'AIOTX (Testnet)',
        symbol: 'AIOTX',
        image: 'assets/logo.png',
        geckoID: '',
        tokenID: 'EQAiboDEv_qRrcEdrYdwbVLNOXBHwShFbtKGbQVJ2OKxY0to',
        mintDecimals: 9,
      ),
    ];
  }

  return [
    TonFungibleCoin.fromParent(
      parent: parent,
      name: 'Notcoin',
      symbol: 'NOT',
      image: 'assets/notcoin.webp',
      geckoID: 'notcoin',
      tokenID: 'EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT',
      mintDecimals: 9,
    ),
    TonFungibleCoin.fromParent(
      parent: parent,
      name: 'Tether USD',
      symbol: 'USDT',
      image: 'assets/usdt.png',
      geckoID: 'tether',
      tokenID: 'EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs',
      mintDecimals: 6,
    ),
  ];
}
