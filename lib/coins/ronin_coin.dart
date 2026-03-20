import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/interface/coin.dart';

import '../utils/app_config.dart';

class RoninCoin extends EthereumCoin {
  RoninCoin({
    required super.blockExplorer,
    required super.chainId,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.coinType,
    required super.rpc,
    required super.name,
    required super.geckoID,
  }) : super(
          rampID: 'RONIN_RON',
          payScheme: 'ronin',
        );

  factory RoninCoin.fromJson(Map<String, dynamic> json) {
    return RoninCoin(
      chainId: json['chainId'],
      rpc: json['rpc'],
      coinType: json['coinType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
    );
  }
  @override
  Future<AccountData> importData(String data) async {
    final mnemonicDetails = await super.importData(data);
    return AccountData.fromJson(
      {
        ...mnemonicDetails.toJson(),
        'address': ethAddrToRonin(mnemonicDetails.address),
      },
    );
  }

  @override
  void validateAddress(String address) {
    super.validateAddress(roninAddrToEth(address));
  }
}

List<RoninCoin> getRoninBlockchains() {
  List<RoninCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      RoninCoin(
        rpc: 'https://saigon-testnet.roninchain.com/rpc',
        chainId: 2021,
        blockExplorer:
            'https://saigon-app.roninchain.com/tx/$blockExplorerPlaceholder',
        symbol: 'RON',
        default_: 'RON',
        name: 'Ronin(Testnet)',
        image: 'assets/ronin.jpeg',
        coinType: 60,
        geckoID: "ronin",
      ),
    ]);
  } else {
    blockChains.addAll([
      RoninCoin(
        rpc: 'https://api.roninchain.com/rpc',
        chainId: 2020,
        blockExplorer:
            'https://app.roninchain.com/tx/$blockExplorerPlaceholder',
        symbol: 'RON',
        default_: 'RON',
        name: 'Ronin',
        image: 'assets/ronin.jpeg',
        coinType: 60,
        geckoID: "ronin",
      )
    ]);
  }

  return blockChains;
}
