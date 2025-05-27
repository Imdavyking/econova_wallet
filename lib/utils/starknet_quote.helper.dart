// ignore_for_file: constant_identifier_names

class StarknetChainId {
  static const String SN_MAIN = "0x534e5f4d41494e";
  static const String SN_SEPOLIA = "0x534e5f5345504f4c4941";
}

class TokenInfo {
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final bool camelCased;
  final UsdcPair? usdcPair;

  TokenInfo({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.camelCased,
    this.usdcPair,
  });

  toJson() {
    return {
      "address": address,
      "symbol": symbol,
      "name": name,
      "decimals": decimals,
      "camelCased": camelCased,
      "usdcPair": usdcPair?.toJson(),
    };
  }
}

class UsdcPair {
  final String address;
  final bool reversed;

  UsdcPair({required this.address, required this.reversed});

  toJson() {
    return {
      "address": address,
      "reversed": reversed,
    };
  }
}

class StarknetHelper {
  static const Map<String, String> ethAddresses = {
    StarknetChainId.SN_SEPOLIA:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
    StarknetChainId.SN_MAIN:
        "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
  };

  static const Map<String, String> strkAddresses = {
    StarknetChainId.SN_SEPOLIA:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
    StarknetChainId.SN_MAIN:
        "0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d",
  };

  static const Map<String, String> usdcAddresses = {
    StarknetChainId.SN_SEPOLIA:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
    StarknetChainId.SN_MAIN:
        "0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8",
  };

  static const Map<String, String> jediswapEthUsdc = {
    StarknetChainId.SN_SEPOLIA:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
    StarknetChainId.SN_MAIN:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
  };

  static const Map<String, String> jediswapStrkUsdc = {
    StarknetChainId.SN_SEPOLIA:
        "0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a",
    StarknetChainId.SN_MAIN:
        "0x5726725e9507c3586cc0516449e2c74d9b201ab2747752bb0251aaa263c9a26",
  };

  static final Map<String, TokenInfo> ether = {
    StarknetChainId.SN_SEPOLIA: TokenInfo(
      address: ethAddresses[StarknetChainId.SN_SEPOLIA]!,
      symbol: "ETH",
      name: "Ether",
      decimals: 18,
      camelCased: true,
      usdcPair: UsdcPair(
        address: jediswapEthUsdc[StarknetChainId.SN_SEPOLIA]!,
        reversed: true,
      ),
    ),
    StarknetChainId.SN_MAIN: TokenInfo(
      address: ethAddresses[StarknetChainId.SN_MAIN]!,
      symbol: "ETH",
      name: "Ether",
      decimals: 18,
      camelCased: true,
      usdcPair: UsdcPair(
        address: jediswapEthUsdc[StarknetChainId.SN_MAIN]!,
        reversed: false,
      ),
    ),
  };

  static final Map<String, TokenInfo> stark = {
    StarknetChainId.SN_SEPOLIA: TokenInfo(
      address: strkAddresses[StarknetChainId.SN_SEPOLIA]!,
      symbol: "STRK",
      name: "Stark",
      decimals: 18,
      camelCased: true,
      usdcPair: UsdcPair(
        address: jediswapStrkUsdc[StarknetChainId.SN_SEPOLIA]!,
        reversed: true,
      ),
    ),
    StarknetChainId.SN_MAIN: TokenInfo(
      address: strkAddresses[StarknetChainId.SN_MAIN]!,
      symbol: "STRK",
      name: "Stark",
      decimals: 18,
      camelCased: true,
      usdcPair: UsdcPair(
        address: jediswapStrkUsdc[StarknetChainId.SN_MAIN]!,
        reversed: false,
      ),
    ),
  };

  static final Map<String, TokenInfo> usdcCoin = {
    StarknetChainId.SN_SEPOLIA: TokenInfo(
      address: usdcAddresses[StarknetChainId.SN_SEPOLIA]!,
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      camelCased: true,
    ),
    StarknetChainId.SN_MAIN: TokenInfo(
      address: usdcAddresses[StarknetChainId.SN_MAIN]!,
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      camelCased: true,
    ),
  };

  static Map<String, Map<String, TokenInfo>> get quoteTokens => {
        StarknetChainId.SN_SEPOLIA: {
          ether[StarknetChainId.SN_SEPOLIA]!.address:
              ether[StarknetChainId.SN_SEPOLIA]!,
          stark[StarknetChainId.SN_SEPOLIA]!.address:
              stark[StarknetChainId.SN_SEPOLIA]!,
          usdcCoin[StarknetChainId.SN_SEPOLIA]!.address:
              usdcCoin[StarknetChainId.SN_SEPOLIA]!,
        },
        StarknetChainId.SN_MAIN: {
          ether[StarknetChainId.SN_MAIN]!.address:
              ether[StarknetChainId.SN_MAIN]!,
          stark[StarknetChainId.SN_MAIN]!.address:
              stark[StarknetChainId.SN_MAIN]!,
          usdcCoin[StarknetChainId.SN_MAIN]!.address:
              usdcCoin[StarknetChainId.SN_MAIN]!,
        }
      };
}
