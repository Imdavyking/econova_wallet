import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58check/bs58check.dart';
import 'package:flutter/foundation.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart' as solana;
import '../main.dart';

class SolTokenInfo {
  final solana.Ed25519HDPublicKey mint;
  final solana.Ed25519HDPublicKey authority;

  final int balance;
  final String delegateOption;
  final String delegate;
  final String state;
  final String isNativeOption;
  final String isNative;
  final int delegateAmt;
  final String closeAuthorityOption;
  final String closeAuthority;

  SolTokenInfo({
    required this.mint,
    required this.authority,
    required this.balance,
    required this.delegateOption,
    required this.delegate,
    required this.state,
    required this.isNativeOption,
    required this.isNative,
    required this.delegateAmt,
    required this.closeAuthorityOption,
    required this.closeAuthority,
  });

  factory SolTokenInfo.decode(Account account) {
    if (account.data is BinaryAccountData) {
      try {
        BinaryAccountData accountData = account.data as BinaryAccountData;

        if (solana.TokenProgram.programId == account.owner) {
          if (accountData.data.length != 165) {
            throw const FormatException('Invalid account data length');
          }

          final bytes = Int8List.fromList(accountData.data);
          final reader = StructReader(bytes.buffer);

          final mint = solana.Ed25519HDPublicKey.fromBase58(
            base58.encode(
              reader.nextBytes(32),
            ),
          );

          final authority = solana.Ed25519HDPublicKey.fromBase58(
            base58.encode(
              reader.nextBytes(32),
            ),
          );

          final balance = uint8ListToNumber(reader.nextBytes(8));

          final delegateOption = base58.encode(reader.nextBytes(4));

          final delegate = base58.encode(reader.nextBytes(32));

          final state = base58.encode(reader.nextBytes(1));

          final isNativeOption = base58.encode(reader.nextBytes(4));

          final isNative = base58.encode(reader.nextBytes(8));

          final delegatedAmount = uint8ListToNumber(reader.nextBytes(8));

          final closeAuthorityOption = base58.encode(reader.nextBytes(4));

          final closeAuthority = base58.encode(reader.nextBytes(32));

          return SolTokenInfo(
            mint: mint,
            authority: authority,
            balance: balance,
            delegateOption: delegateOption,
            delegate: delegate,
            state: state,
            isNativeOption: isNativeOption,
            isNative: isNative,
            delegateAmt: delegatedAmount,
            closeAuthorityOption: closeAuthorityOption,
            closeAuthority: closeAuthority,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        rethrow;
      }
    }
    throw Exception('failed parsing token program');
  }
}

class StructReader {
  StructReader(this._buffer) : _offset = 0;

  void skip(int length) => _offset += length;

  String nextString() {
    final length = _buffer.asByteData(_offset, 4).getInt32(0, Endian.little);
    final rawBytes = _buffer.asUint8List(_offset + 4, length);
    _offset += length + 4;
    final lastZero = rawBytes.indexOf(0);
    if (lastZero == -1) return '';
    return utf8.decode(rawBytes.sublist(0, lastZero));
  }

  Uint8List nextBytes(int length) {
    final bytes = _buffer.asUint8List(_offset, length);
    _offset += length;
    return bytes;
  }

  final ByteBuffer _buffer;
  int _offset;
}
