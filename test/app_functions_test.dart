// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:wallet_app/coins/cosmos_coin.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/erc_fungible_coin.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/interface/keystore.dart';
import 'package:wallet_app/utils/coingecko_ids.dart';
import 'dart:convert';
import 'package:wallet_app/eip/eip681.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/model/seed_phrase_root.dart';
import 'package:wallet_app/utils/cid.dart';
import 'package:wallet_app/utils/alt_ens.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/coin_pay.dart';
import 'package:wallet_app/utils/ethereum_blockies.dart';
import 'package:wallet_app/utils/network_guard.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool networkAvailable = true;
  const mnemonic1Addresses = {
    'Cardano':
        'addr1qy4jrrcfzylccwgqu3su865es52jkf7yzrdu9cw3z84nycnn3zz9lvqj7vs95tej896xkekzkufhpuk64ja7pga2g8kswl6kh2',
    'Cardano (Preprod)':
        'addr_test1qq4jrrcfzylccwgqu3su865es52jkf7yzrdu9cw3z84nycnn3zz9lvqj7vs95tej896xkekzkufhpuk64ja7pga2g8ksdf8km4',
    'ALGO': 'XTNEJTKVSDVMMRR6JZ7P2M2JMOHIUXU2CQAPL6WGEXNJ2L2HUBGW2OVQ6Q',
    'APT': '0xbfef909638ef90885158fdab9f56e216fd811fe25b32ead0bc2a272d66522bb0',
    'ATOM': 'cosmos15yk64u7zc9g9k2yr2wmzeva5qgwxps6yxj00e7',
    'BCH': 'qzpsvg9z6mk3ttd9vmss3rwfdgfd0r7wcuwtmlaskf',
    'BNB': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'Bitcoin (SegWit)': 'bc1q4qw42stdzjqs59xvlrlxr8526e3nunw7mp73te',
    'Bitcoin (Legacy)': '1Ei9UmLQv4o4UJTy5r5mnGFeC9auM3W5P1',
    'Bitcoin (SegWit Test4)': 'tb1qquv9lg5g2r4jkr0ahun0ddfg5xntxjelvmc7t8',
    'Bitcoin (Legacy Test4)': 'muE6mpRPj6EKFQwaoR49cBTy49Bc9x7oq2',
    'CELO': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'CRO_tcro': 'tcro12xhr9keewx46secesqlctta37jvrkntvu0muaq',
    'CRO_cro': 'cro12xhr9keewx46secesqlctta37jvrkntvj6jca3',
    'CRO_evm': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'DASH': 'XoXdZSiN9MWpmVLDFS65GfLHuERoHeuFCj',
    'EGLD': 'erd1v38vje2t7rvccq2utxcamernpvchnshr6r8x4q9l2f0ekd3tqj2qcl7fs7',
    'ETH': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'EVMOS': 'evmos17w0adeg64ky0daxwd2ugyuneellmjgnxpu2u3g',
    'Filecoin': 'f1qid3qslm4jax2jpohkdwomtidgd3x7xa7qvahea',
    'Filecoin(Testnet)': 't1qid3qslm4jax2jpohkdwomtidgd3x7xa7qvahea',
    'FUSE': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'ICX': 'hx136a013895887b56b99d0b1ed27cd1922906646c',
    'INJ': 'inj17w0adeg64ky0daxwd2ugyuneellmjgnxf5vkec',
    'IOTX': 'io1yfpkvk8attt5vxc364jqj3emxvrvhjf8pcuyd8',
    'NEAR': '82b08c7cedd90d57506d15f600a268adfb5b4122fd9380b2f7714f7291d86133',
    'ONE': 'one12t2plmp43a2pqyl8wp5sgwktslnqt2dzd557mp',
    'ONT': 'AebqgJQDoJk5NLzv8kuiAZitPSk782igMx',
    'OSMO': 'osmo15yk64u7zc9g9k2yr2wmzeva5qgwxps6ywful0v',
    'PAS': '5EEFdPstuRzrHReGVFFSqwtvKXHzj7ZBsaEwBXT4Y73x2iSU',
    'POL': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'RON': 'ronin:f39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    'SOL': 'BtELVjZSaWhMat94P9HyasX3Gvpv6C7WHXJGqWdZbwSQ',
    'STRK':
        '0x058ac366fa8dc98e25a85c7343bcca64324c2e7e65c017785c363d1066ce072a',
    'Stacks': 'SP3N7D4F8TDBNPAN7W6CJ5RGF5DAW5MGHNCM7KHP3',
    'Stacks(Test)': 'ST3N7D4F8TDBNPAN7W6CJ5RGF5DAW5MGHNEGTCR6R',
    'SUI': '0xc88ef07b9b8b2fc3b7daad9478f4e1337f01792e2eab9c3794494e610636026e',
    'TON': 'UQAtUn6khf4MxnAB4aQNcDlUPNOsLtU8IOVZbIabFzw9Ketu',
    'TRX': 'TWer2Ygk5TEheHp3TPuYeqxmB6SsGZmaL6',
    'Waves': '3PEYmwpByFsLTkm7BtkcWgdNaLDwEDPEen8',
    'Waves (Testnet)': '3N2XxzVJ78KwqJTgvpVcZEFZDSiAQ2kAWeT',
    'WND': '5EEFdPstuRzrHReGVFFSqwtvKXHzj7ZBsaEwBXT4Y73x2iSU',
    'XION': 'xion15yk64u7zc9g9k2yr2wmzeva5qgwxps6yym4d04',
    'XNO': 'nano_3hn8hsuie854jhtzcg5xunap7jsg7qxtwpihijp5n5tmqznoqpxc98zkojri',
    'XLM': 'GCRN5PMAG5FM5QLCH7BUZPRQ7UIW37LBZLF2BIDEOSG4ZQ6HYRC45ALA',
    'XRP': 'rnrbiYDUYTJS4JVdSV5FtyCj4HFuRjfLKM',
    'XTZ': 'tz1UiMU2fCPen52tf6F8wp1aLpRTEvuct1kW',
    'Zcash (Test)': 'tmLoFfsS1hx5qnazZX6QTn9UoosxTPCYRwz',
    'Zcash': 't1UxWM2wcKHaLeLo7rN6ivUp4CtsdqSwQh8',
    'ZIL': 'zil1d4c4vntch9jpn3fj9d4ugpuap8cmdj7alnrxvv',
  };

  const mnemonic2Addresses = {
    'ZIL': 'zil13y8306gm62960vwyglgfxa0nctms4jy2jskgxz',
    'ONT': 'Ae2rsN6dbMKoYHNGuHq1ZbrrKzYaztMVuc',
    'STRK':
        '0x03f1ccede682fa33fa5ead53468026175250073a0ca434794aad1b358d1b35e1',
    'ICP': 'b4cd4b814a425b8644e81e4161af24315a20dbe14adf2e77f80fd9a5dc51f1f9',
    'ONE': 'one1q9rg4tpssfmgnx35g3sc6rlzlp7ht5pqr8jl05',
    'EGLD': 'erd1245p8vky0clc0cw89h2l6rvcvadg73ffv4glhwh9gwqatlek3erqlle5ac',
    'ICX': 'hx1621355ce9e82899c5f5e1cfee3b99426f139e35',
    'XNO': 'nano_33irdhma4h59muwm9zeqhqg6km9j684agbhzyr3o5ggzqgmknk4z1kqm6j7q',
    'Bitcoin': 'bc1qzd9a563p9hfd93e3e2k3986m3ve0nmy4dtruaf',
    'Bitcoin (Legacy)': '1Q9sh5HmBGVvysWfU8UAyFSMk7k2bzMnYW',
    'Bitcoin (SegWit Test4)': 'tb1q5gnusd9438drgj524l5khuu8d3k5lrnhkv6pc3',
    'Bitcoin (Legacy Test4)': 'n4fpz8NjzHwBkyzHBhSYoAegc7LjWZ175E',
    'Stacks': 'SP2NA77FDECF5422YVK1FPDAAW4MGK24W9DECA8XT',
    'Stacks(Test)': 'ST2NA77FDECF5422YVK1FPDAAW4MGK24W9EQ42CWR',
    'ETH': '0x4AA3f03885Ad09df3d0CD08CD1Fe9cC52Fc43dBF',
    'TON': 'UQA_OzVBYqQdpbZsVQxQFUisWPgl1vryBA7ZTsYp7JKhtA58',
    'SUI': '0x873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2',
    'APT': '0x61d17985e8c78040eea72513cacf3c3f35ba59fad27528c308f6683cf6534a5f',
    'XTZ': 'tz1dSW1iQguZHMEZoAgNTU6VBRcNnyfb5BA7',
    'ETC': '0x5C4b9839FDD8D5156549bE3eD5a00c933AaA3544',
    'BCH': 'qr4rwp766lf2xysphv8wz2qglphuzx5y7gku3hqruj',
    'LTC': 'ltc1qsru3fe2ttd3zgjfhn3r5eqz6tpe5cfzqszg8s7',
    'DASH': 'Xy1VVEXaiJstcmA9Jr1k38rcr3sGn3kQti',
    'TRX': 'TSwpGWaJtfZfyE8kd1NYD1xYgTQUSGLsSM',
    'SOL': '5rxJLW9p2NQPMRjKM1P3B7CQ7v2RASpz45T7QP39bX5W',
    'XLM': 'GA5MO26YHJK7VMDCTODG7DYO5YATNMRYQVTXNMNKKRFYXZOINJYQEXYT',
    'ALGO': 'GYFNCWZJM3NKKXXFIHNDGNL2BLKBMPKA5UZBUWZUQKUIGYWCG5L2SBPB2U',
    'ATOM': 'cosmos1f36h4udjp9yxaewrrgyrv75phtemqsagep85ne',
    'Zcash (Test)': 'tmLDBDEPStxyzcC9Fv8bDNHZmw9n2LWFB7w',
    'Zcash': 't1UNRtPu3WJUVTwwpFQHUWcu2LAhCrwDWuU',
    'Cardano':
        'addr1q9r4l5l6xzsvum2g5s7u99wt630p8qd9xpepf73reyyrmxpqde5sugs7jg27gp04fcq7a9z90gz3ac8mq7p7k5vwedsq34lpxc',
    'Cardano (Preprod)':
        'addr_test1qpr4l5l6xzsvum2g5s7u99wt630p8qd9xpepf73reyyrmxpqde5sugs7jg27gp04fcq7a9z90gz3ac8mq7p7k5vwedsqjrzp28',
    'XRP': 'rQfZM9WRQJmTJeGroRC9pSyEC3jYeXKfuL',
    'Filecoin': 'f16kbqwbyroghqd76fm5j4uiat5vasumclk7nezpa',
    'Filecoin(Testnet)': 't16kbqwbyroghqd76fm5j4uiat5vasumclk7nezpa',
    'DOT': '15jjuhBx4AdCCKN99Tr2cVAbqjNKosFQYuRZRUiDoCQEab7g',
    'WND': '5GoSmMvtCPMiknMdBpo2ULLSz7Ng7ZhGUQh5GBisF7NiQEMY',
  };

  setUp(() async {
    await setUpTestHive();
    pref = await Hive.openBox(secureStorageKey);
    networkAvailable = await NetworkGuard().checkNow();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  final blockInstance = EthereumBlockies();
  final blockInstanceTwo = EthereumBlockies();
  const busdContractAddress = '0xe9e7cea3dedca5984780bafc599bd69add087d56';
  const address = '0x6Acf5505DF3Eada0BF0547FAb88a85b1A2e03F15';
  const addressTwo = '0x3064c83F8b28193d9B6E7c0717754163DDF3C70b';
  const ensAddress = 'vitalik.eth';
  const eip681String =
      'ethereum:ethereum-$busdContractAddress@56/transfer?address=$address&uint256=1000000000000000000';
  const unstoppableAddress = 'brad.crypto';

  test('can encrypt and decrypt in AES', () {
    const word = 'The quick brown fox jumps over the lazy dog';
    const password = '74b-54db-41cd-b316-38b3fe';
    final base64encryption = encryptText(word, password);
    final base64Dencryption = decryptText(base64encryption, password);
    expect(word, base64Dencryption);
  });

  test("BigIntExt convert correctly", () {
    String amount = '10000000000000000000';
    const decimals = 18;
    BigInt result = amount.toBigIntDec(decimals);

    expect(result, BigInt.parse('10000000000000000000000000000000000000'));

    amount = '250000.892384';
    BigInt result2 = amount.toBigIntDec(decimals);

    expect(result2, BigInt.parse('250000892384000000000000'));
    amount = '-250000.892384';
    BigInt result3 = amount.toBigIntDec(decimals);

    expect(result3, BigInt.parse('-250000892384000000000000'));
  });

  test('can generate filecoin cid', () {
    expect(
      genCid(
        jsonEncode(
          {
            "Version": 0,
            "To": "f125p5nhte6kwrigoxrcaxftwpinlgspfnqd2zaui",
            "From": "f153zbrv25wvfrqf2vrvlk2qmpietuu6wexiyerja",
            "Nonce": 0,
            "Value": "10000000000000000000",
            "GasLimit": 1000000000000,
            "GasFeeCap": "10000000",
            "GasPremium": "10000000",
            "Method": 0,
            "Params": ""
          },
        ),
      ),
      'bagaaieranzmqkatxqfe2unslsoqq5n6mmvn5xjri65m2xkiuq4f2ofmmzf5q',
    );
    expect(
      genCid('OMG!', CIDCodes.dagPBCode),
      'bafybeig6xv5nwphfmvcnektpnojts33jqcuam7bmye2pb54adnrtccjlsu',
    );
    expect(
      genCid(
          jsonEncode(
              '🚀🪐⭐💻😅💪🥳😴🎂👉💧📍🌴😪😮🎈🚩🙈😥😰🔵😡✊🍒🐾🎉😇🎤❌😏🌍🌘🥂✋😹📍🙄'),
          CIDCodes.dagPBCode,
          0),
      'QmW5xcH8ydwYtnS8FsMYxZfjpsN6p4YTVv7n5YbvoooZy4',
    );
    expect(
      genCid(jsonEncode({'hello': 'world'})),
      'bagaaierasords4njcts6vs7qvdjfcvgnume4hqohf65zsfguprqphs3icwea',
    );
    expect(
      genCid(jsonEncode(
          {'s39oe93p;;i3i3lL.//dkdkdlaid': 'kskslei3i9aekdkl39zlallk'})),
      'bagaaierafwnjryt63d5n7l2c76blfv7jddxgfeuhl4bvcdzuniggxo2eqngq',
    );
  });

  test('can convert from cid v0 to cid v1', () {
    expect(
      fromV0ToV1('QmW5xcH8ydwYtnS8FsMYxZfjpsN6p4YTVv7n5YbvoooZy4'),
      'bafybeidtdic3panzxksm5vva52ru222wlasitwpuio2vxszuhfgizrhlim',
    );
    expect(
      fromV0ToV1('QmdfTbBqBPQ7VNxZEYEj14VmRuZBkqFbiwReogJgS1zR1n'),
      'bafybeihdwdcefgh4dqkjv67uzcmw7ojee6xedzdetojuzjevtenxquvyku',
    );
    expect(
      fromV0ToV1('QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR'),
      'bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi',
    );
  });

  test('can decode known abis', () {
    expect(solidityFunctionSig('withdraw(uint256)'), '0x2e1a7d4d');
    expect(solidityFunctionSig('ownerOf(uint256)'), '0x6352211e');
    expect(solidityFunctionSig('balanceOf(address)'), '0x70a08231');
    expect(solidityFunctionSig('transfer(address,uint256)'), '0xa9059cbb');
    expect(solidityFunctionSig('approve(address,uint256)'), '0x095ea7b3');
    expect(solidityFunctionSig('solversk()'), '0xffb5eff0');
  });

  test(
    'ellipsify works',
    () {
      expect(
        ellipsify(
            str:
                '0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2'),
        '0x0₁₀₅873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2',
      );
    },
  );

  test('get ethereum address blockie image data and colors', () {
    blockInstance.seedrand(address.toLowerCase());
    HSL color = blockInstance.createColor();
    HSL bgColor = blockInstance.createColor();
    HSL spotColor = blockInstance.createColor();
    List imageData = blockInstance.createImageData();
    expect(solidityKeccak256(json.encode(blockInstance.randseed)),
        '89b8a19e375159267d7d16447f53766cbd210d6b0328779cc897a03a9922b914');
    expect(
        color.toString(), 'H: 25.0 S: 62.20454423791009 L: 50.21168109970711');
    expect(bgColor.toString(),
        'H: 108.0 S: 57.542195253792315 L: 43.62102017906542');
    expect(spotColor.toString(),
        'H: 31.0 S: 48.8115822751129 L: 50.77201500570961');
    expect(solidityKeccak256(json.encode(imageData)),
        'd935e1c2fa18d0a7b7f92604e3ea282ab4572124852411306d70e302fb5447a4');

    // Account two
    blockInstanceTwo.seedrand(addressTwo.toLowerCase());
    HSL colorTwo = blockInstanceTwo.createColor();
    HSL bgColorTwo = blockInstanceTwo.createColor();
    HSL spotColorTwo = blockInstanceTwo.createColor();
    List imageDataTwo = blockInstanceTwo.createImageData();
    expect(solidityKeccak256(json.encode(blockInstanceTwo.randseed)),
        '491a7d9b769c9e62f67019b5ea33b5b100e8a38e55b1efc0680ac4edaaa18f79');
    expect(colorTwo.toString(),
        'H: 240.0 S: 77.89883877052871 L: 42.880431070402466');
    expect(bgColorTwo.toString(),
        'H: 302.0 S: 52.13426684594446 L: 15.5695927401863');
    expect(spotColorTwo.toString(),
        'H: 252.0 S: 74.00470713805626 L: 64.89102061134344');
    expect(solidityKeccak256(json.encode(imageDataTwo)),
        '0da3e2aa1ee73f4caae2c09cd4febd40ebdf3a0128b2e6c4686ec93055f221d7');
  });

  test('javalongToInt accuracy convert java long numbers to int', () {
    expect(blockInstance.javaLongToInt(-32839282839282), 37105934);
  });

  test('CoinPay data is correct', () {
    const scheme = 'ethereum';
    const amount = 10.0;
    final payment =
        CoinPay(amount: amount, recipient: address, coinScheme: scheme).toUri();

    expect(payment, 'ethereum:$address?amount=10.0');

    final parsedUrl = CoinPay.parseUri('$scheme:$address?amount=10.0');
    expect(parsedUrl.amount, 10.0);
    expect(parsedUrl.recipient, address);
    expect(parsedUrl.coinScheme, scheme);
  });

  test('eip681 conversion', () {
    expect(
        EIP681.build(
          prefix: 'ethereum',
          targetAddress: busdContractAddress,
          chainId: '56',
          functionName: 'transfer',
          parameters: {
            'uint256': (1e18).toString(),
            'address': address,
          },
        ),
        eip681String);

    expect(
      solidityKeccak256(json.encode(EIP681.parse(eip681String))),
      '5a9e3c6f895795edc845d1bcc17a8e23fe4e176b887f9fb86e952e8a0a3e2908',
    );
  });

  test('name hash working correctly', () async {
    expect(
      nameHash(unstoppableAddress),
      '0x756e4e998dbffd803c21d23b06cd855cdc7a4b57706c95964a37e24b47c10fc9',
    );

    expect(
      nameHash(ensAddress),
      '0xee6c4522aab0003e8d14cd40a6af439055fd2577951148c14b6cea9a53475835',
    );
  });

  test('ens resolves correctly to address and content hash', () async {
    // Use checkNow() for a real-time socket check — avoids stream timing issues
    // and works on macOS where connectivity_plus.checkConnectivity() is not implemented.
    if (!networkAvailable) {
      debugPrint("Cannot run ENS test: network offline");
      return;
    }
    enableTestNet = false;

    final ensToAddressMap = await ensToAddr(domainName: ensAddress);
    final ensToContentHash =
        await ensToContentHashAndIPFS(cryptoDomainName: ensAddress);

    if (ensToAddressMap.isOk) {
      expect(ensToAddressMap.value.address, startsWith('0x'));
    } else {
      throw Exception(ensToAddressMap.error);
    }

    if (ensToContentHash.isOk) {
      expect(ensToContentHash.value.url, startsWith('https://ipfs.io/ipfs/'));
    } else {
      throw Exception(ensToContentHash.error);
    }
  });

  test('unstoppable domain resolves correctly to address', () async {
    if (!networkAvailable) {
      debugPrint("Cannot run UD domain test: network offline");
      return;
    }
    enableTestNet = false;

    final domainResult = await udResolver(
      domainName: unstoppableAddress,
      currency: 'BTC',
    );
    debugPrint(domainResult.valueOrNull?.address ?? domainResult.error);

    if (domainResult.isOk) {
      expect(domainResult.value.address,
          'bc1q359khn0phg58xgezyqsuuaha28zkwx047c0c3y');
    } else {
      throw Exception(domainResult.error);
    }
  });

  test('test solidity sha3(keccak256) returns correct data', () {
    expect(solidityKeccak256('hello world'),
        '47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad');
  });

  test('validate addresses', () {
    const invalidAddress = 'bc1qzmy4dtruaf';
    for (int i = 0; i < supportedChains.length; i++) {
      Coin blockchainInfo = supportedChains[i];
      switch (blockchainInfo.getDefault()) {
        case 'EGLD':
          blockchainInfo.validateAddress(
              'erd1245p8vky0clc0cw89h2l6rvcvadg73ffv4glhwh9gwqatlek3erqlle5ac');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<AssertionError>()),
          );
          break;
        case 'BTC':
          if (blockchainInfo.getName() == 'Bitcoin (SegWit)') {
            blockchainInfo
                .validateAddress('bc1qzd9a563p9hfd93e3e2k3986m3ve0nmy4dtruaf');
            expect(
              () => blockchainInfo.validateAddress(invalidAddress),
              throwsA(isA<Exception>()),
            );
          }
          break;
        case 'ETH':
          blockchainInfo
              .validateAddress('0x4AA3f03885Ad09df3d0CD08CD1Fe9cC52Fc43dBF');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<ArgumentError>()),
          );
          break;
        case 'SUI':
          blockchainInfo.validateAddress(
              '0x873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'APT':
          blockchainInfo.validateAddress(
              '0x873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'BCH':
          blockchainInfo
              .validateAddress('qr4rwp766lf2xysphv8wz2qglphuzx5y7gku3hqruj');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'LTC':
          blockchainInfo
              .validateAddress('ltc1qsru3fe2ttd3zgjfhn3r5eqz6tpe5cfzqszg8s7');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'DASH':
          blockchainInfo.validateAddress('Xy1VVEXaiJstcmA9Jr1k38rcr3sGn3kQti');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'TRX':
          blockchainInfo.validateAddress('TSwpGWaJtfZfyE8kd1NYD1xYgTQUSGLsSM');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'SOL':
          blockchainInfo
              .validateAddress('5rxJLW9p2NQPMRjKM1P3B7CQ7v2RASpz45T7QP39bX5W');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<ArgumentError>()),
          );
          break;
        case 'XLM':
          blockchainInfo.validateAddress(
              'GA5MO26YHJK7VMDCTODG7DYO5YATNMRYQVTXNMNKKRFYXZOINJYQEXYT');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'ALGO':
          blockchainInfo.validateAddress(
              'GYFNCWZJM3NKKXXFIHNDGNL2BLKBMPKA5UZBUWZUQKUIGYWCG5L2SBPB2U');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'ATOM':
          blockchainInfo
              .validateAddress('cosmos1f36h4udjp9yxaewrrgyrv75phtemqsagep85ne');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'ZEC':
          if (blockchainInfo.getName() == 'Zcash') {
            blockchainInfo
                .validateAddress('t1UNRtPu3WJUVTwwpFQHUWcu2LAhCrwDWuU');
          } else if (blockchainInfo.getName() == 'Zcash (Test)') {
            blockchainInfo
                .validateAddress('tmYyum6WRz3KGE6gaSG499MmMRLsZEhX6PA');
          }

          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'XTZ':
          blockchainInfo
              .validateAddress('tz1RcTV9WGm2Tiok995LncZDgZHFjVXbnnWK');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'ADA':
          blockchainInfo.validateAddress(
              'addr1q9r4l5l6xzsvum2g5s7u99wt630p8qd9xpepf73reyyrmxpqde5sugs7jg27gp04fcq7a9z90gz3ac8mq7p7k5vwedsq34lpxc');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'XRP':
          blockchainInfo.validateAddress('rQfZM9WRQJmTJeGroRC9pSyEC3jYeXKfuL');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'FIL':
          blockchainInfo
              .validateAddress('f1st7wiqbxz5plebdu32jpqgxrcduf2y6p22fmz3i');
          blockchainInfo.validateAddress('f01782');
          blockchainInfo.validateAddress(
              'f3sg22lqqjewwczqcs2cjr3zp6htctbovwugzzut2nkvb366wzn5tp2zkfvu5xrfqhreowiryxump7l5e6jaaq');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'DOT':
          blockchainInfo.validateAddress(
              '15jjuhBx4AdCCKN99Tr2cVAbqjNKosFQYuRZRUiDoCQEab7g');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'TON':
          blockchainInfo.validateAddress(
              'EQA_OzVBYqQdpbZsVQxQFUisWPgl1vryBA7ZTsYp7JKhtFO5');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'STRK':
          blockchainInfo.validateAddress(
              '0x4cfc1947b5079bf68cf28196417e6c4fd5aea837fd4f78337cb2913302d87fa');
          blockchainInfo.validateAddress(
              '0x004F57d3a568B903C6271D1D793eb989c85A8CeEe812B7C1E35f6b5A02AB73c2');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(isA<Exception>()),
          );
          break;
        case 'ZIL':
          blockchainInfo
              .validateAddress('zil13y8306gm62960vwyglgfxa0nctms4jy2jskgxz');
          expect(
            () => blockchainInfo.validateAddress(invalidAddress),
            throwsA(equals('Invalid address')),
          );
          break;

        default:
      }
    }
  });

  test('all blockchain have important fields', () async {
    for (int i = 0; i < supportedChains.length; i++) {
      expect(supportedChains[i].getName(), isNotNull);
      expect(supportedChains[i].getSymbol(), isNotNull);
      expect(supportedChains[i].getDefault(), isNotNull);
      expect(supportedChains[i].getExplorer(), isNotNull);
      expect(supportedChains[i].getImage(), isNotNull);
    }
  });

  test('check if gecko id is in array of ids', () async {
    for (int i = 0; i < supportedChains.length; i++) {
      final geckoId = supportedChains[i].getGeckoId();
      if (geckoId != '') {
        expect(true, coinGeckoIDs.contains(geckoId));
      }
    }
  });

  test('check if keystore generate right address', () async {
    final keystore = {
      "address": "498b5c1c91911f379ca84f0896671bcee2186d48",
      "crypto": {
        "cipher": "aes-128-ctr",
        "ciphertext":
            "2b1882890e2cc0fff29fd7ed8e18f420d9e3c49ac5e81f3c5474c55f92a541a2",
        "cipherparams": {"iv": "f049d0e42f84a32d6bf1d426c9162fcb"},
        "mac":
            "88ff3943873bfd76cd3e3e03168884b7c71da0894964fe7c8591cbb19e8b7e88",
        "kdf": "pbkdf2",
        "kdfparams": {
          "c": 100000,
          "dklen": 32,
          "prf": "hmac-sha256",
          "salt":
              "d885e85f42b9c591d98a4822f6dfccc3af1a52fc2fe0736e0dd3ce8e543a251f"
        }
      },
      "id": "a032b759-f8d0-40a6-aa42-cde8cf0738fe",
      "version": 3
    };
    const privateKey =
        '58939e1efd4e870d18fda99b5189e59b74fe00225cce5529d9e8575011889e93';
    final keyStoreRes = HEX.encode(
      KeyStore.fromKeystore(
        KeyStoreParams(keystore: json.encode(keystore), password: 'good'),
      ),
    );
    expect(
      privateKey,
      keyStoreRes,
    );
  });

  // ─── shared address expectations ────────────────────────────────────────────

// { coinName ?? coinDefault : expectedAddress }
// coinName is used when the same symbol has multiple variants (BTC, ADA, etc.)

// ─── lookup key: name takes priority over symbol ─────────────────────────────

  String coinKey(Coin c) {
    // CRO has three variants with same name — disambiguate by bech32Hrp
    if (c is CosmosCoin && c.getDefault() == 'CRO') return 'CRO_${c.bech32Hrp}';
    if (c is EthereumCoin && c.getDefault() == 'CRO') return 'CRO_evm';
    // For multi-variant coins prefer the name, else fall back to symbol
    const nameKeyed = {
      'Cardano',
      'Cardano (Preprod)',
      'Bitcoin',
      'Bitcoin (SegWit)',
      'Bitcoin (Legacy)',
      'Bitcoin (SegWit Test4)',
      'Bitcoin (Legacy Test4)',
      'Stacks',
      'Stacks(Test)',
      'Filecoin',
      'Filecoin(Testnet)',
      'Waves',
      'Waves (Testnet)',
      'Zcash',
      'Zcash (Test)',
    };
    final name = c.getName();
    return nameKeyed.contains(name) ? name : c.getDefault();
  }

// ─── helper ──────────────────────────────────────────────────────────────────

  Future<void> runAddressTest(
    String mnemonic,
    Map<String, String> expected,
  ) async {
    seedPhraseRoot = await compute(seedFromMnemonic, mnemonic);
    for (final testNet in [true, false]) {
      enableTestNet = testNet;
      supportedChains = await fetchSupportedChains();
      debugPrint(
        '=== ${testNet ? "TESTNET" : "MAINNET"} — ${supportedChains.length} chains ===',
      );
      for (final coin in supportedChains) {
        if (coin.getDefault() != coin.getSymbol()) continue;
        final key = coinKey(coin);
        final want = expected[key];
        if (want == null) continue; // not in map → skip (e.g. Waves Local)
        final got = await coin.importData(mnemonic);
        debugPrint(
            '  [${testNet ? "T" : "M"}] ${coin.getName()} → ${got.address}');
        expect(got.address, want, reason: '${coin.getName()} address mismatch');
      }
    }
  }

// ─── tests ───────────────────────────────────────────────────────────────────

  test('check if seed phrase generates the correct crypto address', () async {
    walletImportType = WalletType.secretPhrase;
    await runAddressTest(testMnemonic1, mnemonic1Addresses);
  });

  test('check if seed phrase 2 generates the correct crypto address', () async {
    walletImportType = WalletType.secretPhrase;
    await runAddressTest(testMnemonic2, mnemonic2Addresses);
  });
  test('user pin length and pin trials is secured and correct.', () async {
    expect(pinLength, greaterThanOrEqualTo(4));
    expect(userPinTrials, greaterThanOrEqualTo(1));
    expect(maximumTransactionToSave, greaterThanOrEqualTo(10));
    expect(maximumBrowserHistoryToSave, greaterThanOrEqualTo(10));
  });

  test('dapp browser signing key are correct.', () {
    expect(personalSignKey, 'Personal');
    expect(normalSignKey, 'Normal Sign');
    expect(typedMessageSignKey, "Typed Message");
  });

  test('can import token from blockchain', () async {
    if (!networkAvailable) {
      debugPrint("Cannot run import token test: network offline");
      return;
    }
    enableTestNet = false;

    final chainCoin = evmFromChainId(56)!;
    final coin = ERCFungibleCoin(
      geckoID: '',
      contractAddress_: busdContractAddress,
      rpc: chainCoin.rpc,
      blockExplorer: chainCoin.blockExplorer,
      chainId: chainCoin.chainId,
      coinType: chainCoin.coinType,
      default_: chainCoin.default_,
      image: '',
      mintDecimals: 18,
      name: '',
      symbol: '',
    );
    final bep20TokenDetails = await coin.getERC20Meta();

    expect(bep20TokenDetails!.name, 'BUSD Token');
    expect(bep20TokenDetails.symbol, 'BUSD');
    expect(bep20TokenDetails.decimals, 18);
  });
}
