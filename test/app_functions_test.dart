import 'package:cryptowallet/coins/fungible_tokens/erc_fungible_coin.dart';
import 'package:cryptowallet/extensions/big_int_ext.dart';
import 'package:cryptowallet/interface/keystore.dart';
import 'package:cryptowallet/utils/all_coins.dart';
import 'dart:convert';
import 'package:cryptowallet/eip/eip681.dart';
import 'package:cryptowallet/interface/coin.dart';
import 'package:cryptowallet/main.dart';
import 'package:cryptowallet/model/seed_phrase_root.dart';
import 'package:cryptowallet/utils/cid.dart';
import 'package:cryptowallet/utils/alt_ens.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:cryptowallet/utils/coin_pay.dart';
import 'package:cryptowallet/utils/ethereum_blockies.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart' as cardano;
import 'package:flutter_test/flutter_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mnemonic =
      'express crane road good warm suggest genre organ cradle tuition strike manual';
  enableTestNet = false;
  setUp(() async {
    await setUpTestHive();
    pref = await Hive.openBox(secureStorageKey);
    getAllBlockchains = await getAllBlockchains_fun();
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
  test('can generate transactionSignLotus cid', () {});

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

  test('get ethereum address blockie image data and colors', () {
    blockInstance.seedrand(address.toLowerCase());
    HSL color = blockInstance.createColor();
    HSL bgColor = blockInstance.createColor();
    HSL spotColor = blockInstance.createColor();
    List imageData = blockInstance.createImageData();
    expect(sha3(json.encode(blockInstance.randseed)),
        '89b8a19e375159267d7d16447f53766cbd210d6b0328779cc897a03a9922b914');
    expect(
        color.toString(), 'H: 25.0 S: 62.20454423791009 L: 50.21168109970711');
    expect(bgColor.toString(),
        'H: 108.0 S: 57.542195253792315 L: 43.62102017906542');
    expect(spotColor.toString(),
        'H: 31.0 S: 48.8115822751129 L: 50.77201500570961');
    expect(sha3(json.encode(imageData)),
        'd935e1c2fa18d0a7b7f92604e3ea282ab4572124852411306d70e302fb5447a4');

    /// Account two
    blockInstanceTwo.seedrand(addressTwo.toLowerCase());
    HSL colorTwo = blockInstanceTwo.createColor();
    HSL bgColorTwo = blockInstanceTwo.createColor();
    HSL spotColorTwo = blockInstanceTwo.createColor();
    List imageDataTwo = blockInstanceTwo.createImageData();
    expect(sha3(json.encode(blockInstanceTwo.randseed)),
        '491a7d9b769c9e62f67019b5ea33b5b100e8a38e55b1efc0680ac4edaaa18f79');
    expect(colorTwo.toString(),
        'H: 240.0 S: 77.89883877052871 L: 42.880431070402466');
    expect(bgColorTwo.toString(),
        'H: 302.0 S: 52.13426684594446 L: 15.5695927401863');
    expect(spotColorTwo.toString(),
        'H: 252.0 S: 74.00470713805626 L: 64.89102061134344');
    expect(sha3(json.encode(imageDataTwo)),
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
      sha3(json.encode(EIP681.parse(eip681String))),
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
    Map ensToAddressMap = await ensToAddr(
      domainName: ensAddress,
    );

    Map ensToContentHash = await ensToContentHashAndIPFS(
      cryptoDomainName: ensAddress,
    );
    if (ensToAddressMap['success']) {
      expect(
        ensToAddressMap['msg'],
        startsWith('0x'),
      );
    } else {
      throw Exception(ensToAddressMap['msg']);
    }

    if (ensToContentHash['success']) {
      expect(
        ensToContentHash['msg'],
        startsWith('https://ipfs.io/ipfs/'),
      );
    } else {
      throw Exception(ensToContentHash['msg']);
    }
  });

  test('unstoppable domain resolves correctly to address', () async {
    const domainAddress = unstoppableAddress;
    Map domainResult = await udResolver(
      domainName: domainAddress,
      currency: 'BTC',
    );
    if (domainResult['success']) {
      expect(domainResult['msg'], 'bc1q359khn0phg58xgezyqsuuaha28zkwx047c0c3y');
    } else {
      throw Exception(domainResult['msg']);
    }
  });
  test('test solidity sha3(keccak256) returns correct data', () {
    expect(sha3('hello world'),
        '47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad');
  });

  test('validate addresses', () {
    const invalidAddress = 'bc1qzmy4dtruaf';
    for (int i = 0; i < getAllBlockchains.length; i++) {
      Coin blockchainInfo = getAllBlockchains[i];
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
          if (blockchainInfo.getName() == 'Bitcoin') {
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
          blockchainInfo.validateAddress('t1UNRtPu3WJUVTwwpFQHUWcu2LAhCrwDWuU');
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
    for (int i = 0; i < getAllBlockchains.length; i++) {
      expect(getAllBlockchains[i].getName(), isNotNull);
      expect(getAllBlockchains[i].getSymbol(), isNotNull);
      expect(getAllBlockchains[i].getDefault(), isNotNull);
      expect(getAllBlockchains[i].getExplorer(), isNotNull);
      expect(getAllBlockchains[i].getImage(), isNotNull);
    }
  });

  test('check if gecko id is in array of ids', () async {
    for (int i = 0; i < getAllBlockchains.length; i++) {
      final geckoId = getAllBlockchains[i].getGeckoId();
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
  test('check if seed phrase generates the correct crypto address', () async {
    // WARNING: These accounts, and their private keys, are publicly known.
    // Any funds sent to them on Mainnet or any other live network WILL BE LOST.
    walletImportType = WalletType.secretPhrase;
    seedPhraseRoot = await compute(seedFromMnemonic, mnemonic);

    for (int i = 0; i < getAllBlockchains.length; i++) {
      Coin blockchainInfo = getAllBlockchains[i];
      AccountData cryptoKeys = await blockchainInfo.importData(mnemonic);
      switch (blockchainInfo.getDefault()) {
        case 'ZIL':
          expect(
            cryptoKeys.address,
            'zil13y8306gm62960vwyglgfxa0nctms4jy2jskgxz',
          );
          break;
        case 'STRK':
          expect(
            cryptoKeys.address,
            '0x3f1ccede682fa33fa5ead53468026175250073a0ca434794aad1b358d1b35e1',
          );
          break;
        case 'ICP':
          expect(
            cryptoKeys.address,
            'b4cd4b814a425b8644e81e4161af24315a20dbe14adf2e77f80fd9a5dc51f1f9',
          );
          break;
        case 'ONE':
          expect(
            cryptoKeys.address,
            'one1q9rg4tpssfmgnx35g3sc6rlzlp7ht5pqr8jl05',
          );
          break;
        case 'EGLD':
          expect(
            cryptoKeys.address,
            'erd1245p8vky0clc0cw89h2l6rvcvadg73ffv4glhwh9gwqatlek3erqlle5ac',
          );
          break;
        case 'BTC':
          if (blockchainInfo.getName() == 'Bitcoin') {
            expect(cryptoKeys.address,
                'bc1qzd9a563p9hfd93e3e2k3986m3ve0nmy4dtruaf');
          } else if (blockchainInfo.getName() == 'Bitcoin(Test)') {
            expect(
              cryptoKeys.address,
              'n4fpz8NjzHwBkyzHBhSYoAegc7LjWZ175E',
            );
          }
          break;
        case 'ETH':
          expect(
            cryptoKeys.address,
            '0x4AA3f03885Ad09df3d0CD08CD1Fe9cC52Fc43dBF',
          );

          break;

        case 'TON':
          expect(
            cryptoKeys.address,
            'EQA_OzVBYqQdpbZsVQxQFUisWPgl1vryBA7ZTsYp7JKhtFO5',
          );

          break;
        case 'SUI':
          expect(
            cryptoKeys.address,
            '0x873e40399c80eec9d2acccd938570b06d146c4dd1241318ff4c2874e3c8631a2',
          );
          break;
        case 'APT':
          expect(
            cryptoKeys.address,
            '0x61d17985e8c78040eea72513cacf3c3f35ba59fad27528c308f6683cf6534a5f',
          );
          break;
        case 'ETC':
          expect(
            cryptoKeys.address,
            '0x5C4b9839FDD8D5156549bE3eD5a00c933AaA3544',
          );

          break;
        case 'BCH':
          expect(
              cryptoKeys.address, 'qr4rwp766lf2xysphv8wz2qglphuzx5y7gku3hqruj');
          break;
        case 'LTC':
          expect(cryptoKeys.address,
              'ltc1qsru3fe2ttd3zgjfhn3r5eqz6tpe5cfzqszg8s7');

          break;
        case 'DASH':
          expect(cryptoKeys.address, 'Xy1VVEXaiJstcmA9Jr1k38rcr3sGn3kQti');

          break;
        case 'TRX':
          expect(cryptoKeys.address, 'TSwpGWaJtfZfyE8kd1NYD1xYgTQUSGLsSM');

          break;
        case 'SOL':
          expect(
            cryptoKeys.address,
            '5rxJLW9p2NQPMRjKM1P3B7CQ7v2RASpz45T7QP39bX5W',
          );

          break;
        case 'XLM':
          expect(cryptoKeys.address,
              'GA5MO26YHJK7VMDCTODG7DYO5YATNMRYQVTXNMNKKRFYXZOINJYQEXYT');

          break;
        case 'ALGO':
          expect(cryptoKeys.address,
              'GYFNCWZJM3NKKXXFIHNDGNL2BLKBMPKA5UZBUWZUQKUIGYWCG5L2SBPB2U');

          break;
        case 'ATOM':
          expect(cryptoKeys.address,
              'cosmos1f36h4udjp9yxaewrrgyrv75phtemqsagep85ne');

          break;
        case 'ZEC':
          expect(cryptoKeys.address, 't1UNRtPu3WJUVTwwpFQHUWcu2LAhCrwDWuU');
          break;

        case 'ADA':
          if (blockchainInfo.getName() == 'Cardano') {
            expect(
              cryptoKeys.address,
              'addr1q9r4l5l6xzsvum2g5s7u99wt630p8qd9xpepf73reyyrmxpqde5sugs7jg27gp04fcq7a9z90gz3ac8mq7p7k5vwedsq34lpxc',
            );
          } else if (blockchainInfo.getName() == 'Cardano(Prepod)') {
            expect(
              cryptoKeys.address,
              'addr_test1qpr4l5l6xzsvum2g5s7u99wt630p8qd9xpepf73reyyrmxpqde5sugs7jg27gp04fcq7a9z90gz3ac8mq7p7k5vwedsqjrzp28',
            );
          }

          break;
        case 'XRP':
          expect(cryptoKeys.address, 'rQfZM9WRQJmTJeGroRC9pSyEC3jYeXKfuL');

          break;
        case 'FIL':
          if (blockchainInfo.getName() == 'Filecoin') {
            expect(cryptoKeys.address,
                'f16kbqwbyroghqd76fm5j4uiat5vasumclk7nezpa');
          } else if (blockchainInfo.getName() == 'Filecoin(Testnet)') {
            expect(
              cryptoKeys.address,
              't16kbqwbyroghqd76fm5j4uiat5vasumclk7nezpa',
            );
          }

          break;
        case 'DOT':
          expect(
            cryptoKeys.address,
            '15jjuhBx4AdCCKN99Tr2cVAbqjNKosFQYuRZRUiDoCQEab7g',
          );

          break;
        default:
      }
    }
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
