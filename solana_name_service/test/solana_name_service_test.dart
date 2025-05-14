import 'package:flutter_test/flutter_test.dart';
import 'package:solana/solana.dart';
import 'package:solana_name_service/solana_name_service.dart';

void main() {
  group('Solana name service', () {
    const environment = SolanaEnvironment.mainnet;
    print("testing with URL: ${urlMap[environment]}");

    test('Find owned accounts succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV");
      var accts =
          await findOwnedNameAccountsForUser(pubKey, environment: environment);
      expect(accts.length, equals(4));
    });

    test('Fetch name success', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV");
      final name = await fetchSolanaNameServiceName(pubKey.toBase58(),
          environment: environment);
      expect(name, equals("kdingens"));
    });

    test('Find public key by name', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV");
      final owner =
          await findAccountByName("kdingens", environment: environment);
      expect(owner, equals(pubKey));
    });

    test('Find favorite domain name succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV");
      final name =
          await findFavoriteDomainName(pubKey, environment: environment);
      expect(name, equals("kdingens"));
    });
  });
}
