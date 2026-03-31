// ignore_for_file: unused_element

import 'dart:math';
import 'package:pinenacl/encoding.dart';
import 'package:pinenacl/key_derivation.dart';
import 'package:pinenacl/tweetnacl.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _radixBits = 10;
const _identifierBitsLength = 15;
const _iterationExponentBitsLength = 4;
const _extendableBackupFlagBitsLength = 1;
const _identifierExpWordsLength = (_identifierBitsLength +
        _iterationExponentBitsLength +
        _extendableBackupFlagBitsLength +
        _radixBits -
        1) ~/
    _radixBits;
const _maxShareCount = 16;
const _checksumWordsLength = 3;
const _digestLength = 4;
const _saltString = 'shamir';
const _saltStringExtendable = 'shamir_extendable';
const _minEntropyBits = 128;
const _metadataWordsLength =
    _identifierExpWordsLength + 2 + _checksumWordsLength;
const _minMnemonicWordsLength =
    _metadataWordsLength + (_minEntropyBits + _radixBits - 1) ~/ _radixBits;
const _iterationCount = 10000;
const _roundCount = 4;
const _digestIndex = 254;
const _secretIndex = 255;

// ── Typed data classes ────────────────────────────────────────────────────────

/// A single decoded SLIP39 mnemonic share.
final class DecodedShare {
  const DecodedShare({
    required this.identifier,
    required this.iterationExponent,
    required this.extendableBackupFlag,
    required this.groupIndex,
    required this.groupThreshold,
    required this.groupCount,
    required this.memberIndex,
    required this.memberThreshold,
    required this.share,
  });

  final int identifier;
  final int iterationExponent;
  final int extendableBackupFlag;
  final int groupIndex;
  final int groupThreshold;
  final int groupCount;
  final int memberIndex;
  final int memberThreshold;
  final Uint8List share;
}

/// One group's worth of decoded member shares, keyed by member index.
final class ShareGroup {
  ShareGroup({required this.memberThreshold});

  final int memberThreshold;
  final List<(int index, Uint8List share)> members = [];

  int get count => members.length;

  bool get isComplete => count == memberThreshold;

  void add(int memberIndex, Uint8List share) =>
      members.add((memberIndex, share));

  /// Returns the members as an index→share map for interpolation.
  Map<int, Uint8List> toInterpolationMap() =>
      {for (final (idx, s) in members) idx: s};
}

/// The fully decoded set of mnemonics, ready for secret recovery.
final class DecodedMnemonics {
  const DecodedMnemonics({
    required this.identifier,
    required this.iterationExponent,
    required this.extendableBackupFlag,
    required this.groupThreshold,
    required this.groupCount,
    required this.groups,
  });

  final int identifier;
  final int iterationExponent;
  final int extendableBackupFlag;
  final int groupThreshold;
  final int groupCount;
  final List<ShareGroup> groups;
}

// ── Internal helpers ──────────────────────────────────────────────────────────

int _bitsToBytes(int n) => (n + 7) ~/ 8;
int _bitsToWords(int n) => (n + _radixBits - 1) ~/ _radixBits;

final _random = Random.secure();

List<int> _randomBytes([int length = 32]) =>
    List.generate(length, (_) => _random.nextInt(256));

Uint8List _roundFunction(
  int i,
  Uint8List passphrase,
  int exp,
  Uint8List salt,
  Uint8List r,
) {
  final saltAndR = Uint8List.fromList(salt + r);
  final roundedPhrase = Uint8List.fromList([i, ...passphrase]);
  final count = (_iterationCount << exp) ~/ _roundCount;
  return PBKDF2.hmac_sha256(roundedPhrase, saltAndR, count, r.length);
}

Uint8List _crypt(
  Uint8List masterSecret,
  String passphrase,
  int iterationExponent,
  int extendableBackupFlag,
  Uint8List identifier, {
  bool encrypt = true,
}) {
  final maxExp = pow(2, _iterationExponentBitsLength);
  if (iterationExponent < 0 || iterationExponent > maxExp) {
    throw Exception(
        'Invalid iteration exponent ($iterationExponent). Expected between 0 and $maxExp.');
  }

  var iL = masterSecret.sublist(0, masterSecret.length ~/ 2);
  var iR = masterSecret.sublist(masterSecret.length ~/ 2);

  final pwd = Uint8List.fromList(passphrase.codeUnits);
  final salt = _buildSalt(identifier, extendableBackupFlag);
  final rounds = List.generate(_roundCount, (i) => i);
  final orderedRounds = encrypt ? rounds : rounds.reversed.toList();

  for (final i in orderedRounds) {
    final f = _roundFunction(i, pwd, iterationExponent, salt, iR);
    final t = _xor(iL, f);
    iL = iR;
    iR = t;
  }

  return Uint8List.fromList(iR + iL);
}

Uint8List _createDigest(Uint8List randomData, Uint8List sharedSecret) {
  final out = Uint8List(32);
  TweetNaClExt.crypto_auth_hmacsha256(out, sharedSecret, randomData);
  return out.sublist(0, _digestLength);
}

List<Uint8List> _splitSecret(
  int threshold,
  int shareCount,
  Uint8List sharedSecret,
) {
  if (threshold <= 0) {
    throw Exception(
        'The requested threshold ($threshold) must be a positive integer.');
  }
  if (threshold > shareCount) {
    throw Exception(
        'The requested threshold ($threshold) must not exceed the number of shares ($shareCount).');
  }
  if (shareCount > _maxShareCount) {
    throw Exception(
        'The requested number of shares ($shareCount) must not exceed $_maxShareCount.');
  }

  // When threshold is 1, every share IS the secret — no digest needed.
  if (threshold == 1) {
    return List.generate(shareCount, (_) => sharedSecret);
  }

  final randomShareCount = threshold - 2;
  final randomPart =
      Uint8List.fromList(_randomBytes(sharedSecret.length - _digestLength));
  final digest = _createDigest(randomPart, sharedSecret);

  // Start with [threshold-2] purely random shares.
  final shares = List.generate(randomShareCount,
      (_) => Uint8List.fromList(_randomBytes(sharedSecret.length)));

  // Build the interpolation base: random shares + digest share + secret share.
  final baseShares = <int, Uint8List>{
    for (var i = 0; i < randomShareCount; i++) i: shares[i],
    _digestIndex: Uint8List.fromList(digest + randomPart),
    _secretIndex: sharedSecret,
  };

  // Derive the remaining shares via interpolation.
  for (var i = randomShareCount; i < shareCount; i++) {
    shares.add(Uint8List.fromList(_interpolate(baseShares, i)));
  }

  return shares;
}

Uint8List _generateIdentifier() {
  final byteCount = _bitsToBytes(_identifierBitsLength);
  const bits = _identifierBitsLength % 8;
  final identifier = _randomBytes(byteCount);
  identifier[0] = identifier[0] & ((1 << bits) - 1);
  return Uint8List.fromList(identifier);
}

Uint8List _xor(Uint8List a, Uint8List b) {
  if (a.length != b.length) {
    throw Exception(
        'XOR operands must have equal length (${a.length} vs ${b.length}).');
  }
  return Uint8List.fromList(List.generate(a.length, (i) => a[i] ^ b[i]));
}

Uint8List _buildSalt(Uint8List identifier, int extendableBackupFlag) {
  if (extendableBackupFlag == 1) return Uint8List(0);
  return Uint8List.fromList(_saltString.codeUnits + identifier);
}

List<int> _interpolate(Map<int, Uint8List> shares, int x) {
  final shareLength = shares.values.map((v) => v.length).toSet();
  if (shareLength.length != 1) {
    throw Exception(
        'Invalid set of shares. All share values must have the same length.');
  }

  if (shares.containsKey(x)) return shares[x]!;

  var logProd = 0;
  for (final k in shares.keys) {
    logProd += _logTable[k ^ x];
  }

  final result = List<int>.filled(shareLength.first, 0);

  shares.forEach((k, v) {
    var logBasisSum = 0;
    for (final kk in shares.keys) {
      logBasisSum += _logTable[k ^ kk];
    }
    final logBasisEval = (logProd - _logTable[k ^ x] - logBasisSum) % 255;

    for (var i = 0; i < v.length; i++) {
      final shareVal = v[i];
      final r = shareVal != 0
          ? _expTable[(_logTable[shareVal] + logBasisEval) % 255]
          : 0;
      result[i] ^= r;
    }
  });

  return result;
}

int _rs1024Polymod(List<int> values) {
  const gen = [
    0xE0E040,
    0x1C1C080,
    0x3838100,
    0x7070200,
    0xE0E0009,
    0x1C0C2412,
    0x38086C24,
    0x3090FC48,
    0x21B1F890,
    0x3F3F120,
  ];

  var chk = 1;
  for (final v in values) {
    final b = chk >> 20;
    chk = (chk & 0xFFFFF) << 10 ^ v;
    for (var i = 0; i < 10; i++) {
      chk ^= ((b >> i) & 1) != 0 ? gen[i] : 0;
    }
  }
  return chk;
}

String _checksumSalt(int extendableBackupFlag) =>
    extendableBackupFlag == 1 ? _saltStringExtendable : _saltString;

List<int> _rs1024CreateChecksum(List<int> data, int extendableBackupFlag) {
  final values = [
    ..._checksumSalt(extendableBackupFlag).codeUnits,
    ...data,
    ...List<int>.filled(_checksumWordsLength, 0),
  ];
  final polymod = _rs1024Polymod(values) ^ 1;
  return List.generate(
          _checksumWordsLength, (i) => (polymod >> (10 * i)) & 1023)
      .reversed
      .toList();
}

bool _rs1024VerifyChecksum(List<int> data, int extendableBackupFlag) =>
    _rs1024Polymod(
        [..._checksumSalt(extendableBackupFlag).codeUnits, ...data]) ==
    1;

BigInt _intFromIndices(List<int> indices) {
  var value = BigInt.zero;
  final radix = BigInt.from(1 << _radixBits);
  for (final index in indices) {
    value = value * radix + BigInt.from(index);
  }
  return value;
}

List<int> _intToIndices(BigInt value, int length, int bits) {
  final mask = BigInt.from((1 << bits) - 1);
  return List.generate(length, (i) => ((value >> (i * bits)) & mask).toInt())
      .reversed
      .toList();
}

String _mnemonicFromIndices(List<int> indices) =>
    indices.map((i) => _wordList[i]).join(' ');

List<int> _mnemonicToIndices(String mnemonic) {
  return mnemonic.toLowerCase().split(' ').map((word) {
    final index = _wordListMap[word];
    if (index == null) throw Exception('Invalid mnemonic word "$word".');
    return index;
  }).toList();
}

Uint8List _recoverSecret(int threshold, Map<int, Uint8List> shares) {
  if (threshold == 1) return shares.values.first;

  final sharedSecret = _interpolate(shares, _secretIndex);
  final digestShare = _interpolate(shares, _digestIndex);
  final digest = digestShare.sublist(0, _digestLength);
  final randomPart = digestShare.sublist(_digestLength);

  final recoveredDigest = _createDigest(
    Uint8List.fromList(randomPart),
    Uint8List.fromList(sharedSecret),
  );

  if (!_listsEqual(digest, recoveredDigest)) {
    throw Exception('Invalid digest of the shared secret.');
  }

  return Uint8List.fromList(sharedSecret);
}

List<int> _groupPrefix(
  int identifier,
  int iterationExponent,
  int extendableBackupFlag,
  int groupIndex,
  int groupThreshold,
  int groupCount,
) {
  final idExpInt = BigInt.from(
    (identifier <<
            (_iterationExponentBitsLength + _extendableBackupFlagBitsLength)) +
        (extendableBackupFlag << _iterationExponentBitsLength) +
        iterationExponent,
  );
  return [
    ..._intToIndices(idExpInt, _identifierExpWordsLength, _radixBits),
    (groupIndex << 6) + ((groupThreshold - 1) << 2) + ((groupCount - 1) >> 2),
  ];
}

bool _listsEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _encodeMnemonic(
  Uint8List identifier,
  int iterationExponent,
  int extendableBackupFlag,
  int groupIndex,
  int groupThreshold,
  int groupCount,
  int memberIndex,
  int memberThreshold,
  Uint8List value,
) {
  final valueWordCount = _bitsToWords(value.length * 8);
  final valueInt = _decodeBigInt(value);
  final id = int.parse(Base16Encoder.instance.encode(identifier), radix: 16);

  final shareData = [
    ..._groupPrefix(id, iterationExponent, extendableBackupFlag, groupIndex,
        groupThreshold, groupCount),
    (((groupCount - 1) & 3) << 8) + (memberIndex << 4) + (memberThreshold - 1),
    ..._intToIndices(valueInt, valueWordCount, _radixBits),
  ];

  return _mnemonicFromIndices(
      shareData + _rs1024CreateChecksum(shareData, extendableBackupFlag));
}

DecodedShare _decodeMnemonic(String mnemonic) {
  final data = _mnemonicToIndices(mnemonic);

  if (data.length < _minMnemonicWordsLength) {
    throw Exception(
        'Invalid mnemonic length. Each mnemonic must be at least $_minMnemonicWordsLength words.');
  }

  final paddingLen = (_radixBits * (data.length - _metadataWordsLength)) % 16;
  if (paddingLen > 8) throw Exception('Invalid mnemonic length.');

  final idExpInt =
      _intFromIndices(data.sublist(0, _identifierExpWordsLength)).toInt();
  final identifier = idExpInt >>
      (_iterationExponentBitsLength + _extendableBackupFlagBitsLength);
  final iterationExponent =
      idExpInt & ((1 << _iterationExponentBitsLength) - 1);
  final extendableBackupFlag = (idExpInt >> _iterationExponentBitsLength) &
      ((1 << _extendableBackupFlagBitsLength) - 1);

  if (!_rs1024VerifyChecksum(data, extendableBackupFlag)) {
    throw Exception('Invalid mnemonic checksum.');
  }

  final tmp = _intFromIndices(
      data.sublist(_identifierExpWordsLength, _identifierExpWordsLength + 2));
  final indices = _intToIndices(tmp, 5, 4);

  final groupIndex = indices[0];
  final groupThreshold = indices[1];
  final groupCount = indices[2];
  final memberIndex = indices[3];
  final memberThreshold = indices[4];

  if (groupCount < groupThreshold) {
    throw Exception(
        'Invalid mnemonic: group threshold ($groupThreshold) cannot exceed group count ($groupCount).');
  }

  final valueData = data.sublist(
      _identifierExpWordsLength + 2, data.length - _checksumWordsLength);
  final valueInt = _intFromIndices(valueData);
  final valueByteCount =
      _bitsToBytes(_radixBits * valueData.length - paddingLen);

  var shareBytes = _encodeBigInt(valueInt);
  if (shareBytes.length > valueByteCount) {
    throw Exception('Mnemonic padding error.');
  }
  if (shareBytes.length < valueByteCount) {
    shareBytes = Uint8List.fromList(
        Uint8List(valueByteCount - shareBytes.length) + shareBytes);
  }

  return DecodedShare(
    identifier: identifier,
    iterationExponent: iterationExponent,
    extendableBackupFlag: extendableBackupFlag,
    groupIndex: groupIndex,
    groupThreshold: groupThreshold + 1,
    groupCount: groupCount + 1,
    memberIndex: memberIndex,
    memberThreshold: memberThreshold + 1,
    share: shareBytes,
  );
}

Uint8List _encodeBigInt(BigInt number) {
  final size = (number.bitLength + 7) >> 3;
  final result = Uint8List(size);
  var n = number;
  final mask = BigInt.parse('0xff');
  for (var i = 0; i < size; i++) {
    result[size - i - 1] = (n & mask).toInt();
    n >>= 8;
  }
  return result;
}

BigInt _decodeBigInt(List<int> bytes) {
  var result = BigInt.zero;
  for (var i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

// ── Public API ────────────────────────────────────────────────────────────────

/// Decodes a list of mnemonic strings into a [DecodedMnemonics] structure.
///
/// Throws if the mnemonics are inconsistent (mixed identifiers, thresholds, etc.).
DecodedMnemonics decodeMnemonics(List<String> mnemonics) {
  if (mnemonics.isEmpty) throw Exception('The list of mnemonics is empty.');

  int? identifier;
  int? iterationExponent;
  int? extendableBackupFlag;
  int? groupThreshold;
  int? groupCount;

  // groups[groupIndex] holds that group's ShareGroup.
  final groups = <int, ShareGroup>{};

  for (final mnemonic in mnemonics) {
    final d = _decodeMnemonic(mnemonic);

    // Validate cross-mnemonic consistency.
    identifier ??= d.identifier;
    iterationExponent ??= d.iterationExponent;
    extendableBackupFlag ??= d.extendableBackupFlag;
    groupThreshold ??= d.groupThreshold;
    groupCount ??= d.groupCount;

    if (d.identifier != identifier ||
        d.iterationExponent != iterationExponent ||
        d.extendableBackupFlag != extendableBackupFlag) {
      throw Exception(
          'All mnemonics must begin with the same $_identifierExpWordsLength words.');
    }
    if (d.groupThreshold != groupThreshold) {
      throw Exception('All mnemonics must have the same group threshold.');
    }
    if (d.groupCount != groupCount) {
      throw Exception('All mnemonics must have the same group count.');
    }

    final group = groups.putIfAbsent(
      d.groupIndex,
      () => ShareGroup(memberThreshold: d.memberThreshold),
    );

    if (group.memberThreshold != d.memberThreshold) {
      throw Exception(
          'All mnemonics in a group must have the same member threshold.');
    }

    group.add(d.memberIndex, d.share);
  }

  return DecodedMnemonics(
    identifier: identifier!,
    iterationExponent: iterationExponent!,
    extendableBackupFlag: extendableBackupFlag!,
    groupThreshold: groupThreshold!,
    groupCount: groupCount!,
    groups: groups.values.toList(),
  );
}

/// Combines [mnemonics] to recover the original master secret.
///
/// Supply the same [passphrase] used during share creation (empty string if none).
List<int> combineMnemonics(List<String> mnemonics, {String passphrase = ''}) {
  final decoded = decodeMnemonics(mnemonics);

  if (decoded.groups.length < decoded.groupThreshold) {
    throw Exception(
        'Insufficient number of mnemonic groups (${decoded.groups.length}). '
        'Required: ${decoded.groupThreshold}.');
  }

  if (decoded.groups.length != decoded.groupThreshold) {
    throw Exception('Wrong number of mnemonic groups. '
        'Expected ${decoded.groupThreshold}, got ${decoded.groups.length}.');
  }

  // Recover each group's secret, then combine them.
  final groupSecrets = <int, Uint8List>{};
  for (var i = 0; i < decoded.groups.length; i++) {
    final group = decoded.groups[i];
    if (!group.isComplete) {
      final prefix = _groupPrefix(
        decoded.identifier,
        decoded.iterationExponent,
        decoded.extendableBackupFlag,
        i,
        decoded.groupThreshold,
        decoded.groupCount,
      );
      throw Exception(
          'Wrong number of mnemonics. Expected ${group.memberThreshold} '
          'mnemonics starting with "${_mnemonicFromIndices(prefix)}", '
          'but ${group.count} were provided.');
    }
    groupSecrets[i] = _recoverSecret(
      group.memberThreshold,
      group.toInterpolationMap(),
    );
  }

  final ems = _recoverSecret(decoded.groupThreshold, groupSecrets);
  final idBytes = Uint8List.fromList(_intToIndices(
      BigInt.from(decoded.identifier), _identifierExpWordsLength, 8));

  return _crypt(
    ems,
    passphrase,
    decoded.iterationExponent,
    decoded.extendableBackupFlag,
    idBytes,
    encrypt: false,
  );
}

bool validateMnemonic(String mnemonic) {
  try {
    _decodeMnemonic(mnemonic);
    return true;
  } catch (_) {
    return false;
  }
}

// ── Lookup tables ─────────────────────────────────────────────────────────────

const _expTable = [
  1,
  3,
  5,
  15,
  17,
  51,
  85,
  255,
  26,
  46,
  114,
  150,
  161,
  248,
  19,
  53,
  95,
  225,
  56,
  72,
  216,
  115,
  149,
  164,
  247,
  2,
  6,
  10,
  30,
  34,
  102,
  170,
  229,
  52,
  92,
  228,
  55,
  89,
  235,
  38,
  106,
  190,
  217,
  112,
  144,
  171,
  230,
  49,
  83,
  245,
  4,
  12,
  20,
  60,
  68,
  204,
  79,
  209,
  104,
  184,
  211,
  110,
  178,
  205,
  76,
  212,
  103,
  169,
  224,
  59,
  77,
  215,
  98,
  166,
  241,
  8,
  24,
  40,
  120,
  136,
  131,
  158,
  185,
  208,
  107,
  189,
  220,
  127,
  129,
  152,
  179,
  206,
  73,
  219,
  118,
  154,
  181,
  196,
  87,
  249,
  16,
  48,
  80,
  240,
  11,
  29,
  39,
  105,
  187,
  214,
  97,
  163,
  254,
  25,
  43,
  125,
  135,
  146,
  173,
  236,
  47,
  113,
  147,
  174,
  233,
  32,
  96,
  160,
  251,
  22,
  58,
  78,
  210,
  109,
  183,
  194,
  93,
  231,
  50,
  86,
  250,
  21,
  63,
  65,
  195,
  94,
  226,
  61,
  71,
  201,
  64,
  192,
  91,
  237,
  44,
  116,
  156,
  191,
  218,
  117,
  159,
  186,
  213,
  100,
  172,
  239,
  42,
  126,
  130,
  157,
  188,
  223,
  122,
  142,
  137,
  128,
  155,
  182,
  193,
  88,
  232,
  35,
  101,
  175,
  234,
  37,
  111,
  177,
  200,
  67,
  197,
  84,
  252,
  31,
  33,
  99,
  165,
  244,
  7,
  9,
  27,
  45,
  119,
  153,
  176,
  203,
  70,
  202,
  69,
  207,
  74,
  222,
  121,
  139,
  134,
  145,
  168,
  227,
  62,
  66,
  198,
  81,
  243,
  14,
  18,
  54,
  90,
  238,
  41,
  123,
  141,
  140,
  143,
  138,
  133,
  148,
  167,
  242,
  13,
  23,
  57,
  75,
  221,
  124,
  132,
  151,
  162,
  253,
  28,
  36,
  108,
  180,
  199,
  82,
  246,
];

const _logTable = [
  0,
  0,
  25,
  1,
  50,
  2,
  26,
  198,
  75,
  199,
  27,
  104,
  51,
  238,
  223,
  3,
  100,
  4,
  224,
  14,
  52,
  141,
  129,
  239,
  76,
  113,
  8,
  200,
  248,
  105,
  28,
  193,
  125,
  194,
  29,
  181,
  249,
  185,
  39,
  106,
  77,
  228,
  166,
  114,
  154,
  201,
  9,
  120,
  101,
  47,
  138,
  5,
  33,
  15,
  225,
  36,
  18,
  240,
  130,
  69,
  53,
  147,
  218,
  142,
  150,
  143,
  219,
  189,
  54,
  208,
  206,
  148,
  19,
  92,
  210,
  241,
  64,
  70,
  131,
  56,
  102,
  221,
  253,
  48,
  191,
  6,
  139,
  98,
  179,
  37,
  226,
  152,
  34,
  136,
  145,
  16,
  126,
  110,
  72,
  195,
  163,
  182,
  30,
  66,
  58,
  107,
  40,
  84,
  250,
  133,
  61,
  186,
  43,
  121,
  10,
  21,
  155,
  159,
  94,
  202,
  78,
  212,
  172,
  229,
  243,
  115,
  167,
  87,
  175,
  88,
  168,
  80,
  244,
  234,
  214,
  116,
  79,
  174,
  233,
  213,
  231,
  230,
  173,
  232,
  44,
  215,
  117,
  122,
  235,
  22,
  11,
  245,
  89,
  203,
  95,
  176,
  156,
  169,
  81,
  160,
  127,
  12,
  246,
  111,
  23,
  196,
  73,
  236,
  216,
  67,
  31,
  45,
  164,
  118,
  123,
  183,
  204,
  187,
  62,
  90,
  251,
  96,
  177,
  134,
  59,
  82,
  161,
  108,
  170,
  85,
  41,
  157,
  151,
  178,
  135,
  144,
  97,
  190,
  220,
  252,
  188,
  149,
  207,
  205,
  55,
  63,
  91,
  209,
  83,
  57,
  132,
  60,
  65,
  162,
  109,
  71,
  20,
  42,
  158,
  93,
  86,
  242,
  211,
  171,
  68,
  17,
  146,
  217,
  35,
  32,
  46,
  137,
  180,
  124,
  184,
  38,
  119,
  153,
  227,
  165,
  103,
  74,
  237,
  222,
  197,
  49,
  254,
  24,
  13,
  99,
  140,
  128,
  192,
  247,
  112,
  7,
];

// ── SLIP39 wordlist ───────────────────────────────────────────────────────────

const _wordList = [
  'academic',
  'acid',
  'acne',
  'acquire',
  'acrobat',
  'activity',
  'actress',
  'adapt',
  'adequate',
  'adjust',
  'admit',
  'adorn',
  'adult',
  'advance',
  'advocate',
  'afraid',
  'again',
  'agency',
  'agree',
  'aide',
  'aircraft',
  'airline',
  'airport',
  'ajar',
  'alarm',
  'album',
  'alcohol',
  'alien',
  'alive',
  'alpha',
  'already',
  'alto',
  'aluminum',
  'always',
  'amazing',
  'ambition',
  'amount',
  'amuse',
  'analysis',
  'anatomy',
  'ancestor',
  'ancient',
  'angel',
  'angry',
  'animal',
  'answer',
  'antenna',
  'anxiety',
  'apart',
  'aquatic',
  'arcade',
  'arena',
  'argue',
  'armed',
  'artist',
  'artwork',
  'aspect',
  'auction',
  'august',
  'aunt',
  'average',
  'aviation',
  'avoid',
  'award',
  'away',
  'axis',
  'axle',
  'beam',
  'beard',
  'beaver',
  'become',
  'bedroom',
  'behavior',
  'being',
  'believe',
  'belong',
  'benefit',
  'best',
  'beyond',
  'bike',
  'biology',
  'birthday',
  'bishop',
  'black',
  'blanket',
  'blessing',
  'blimp',
  'blind',
  'blue',
  'body',
  'bolt',
  'boring',
  'born',
  'both',
  'boundary',
  'bracelet',
  'branch',
  'brave',
  'breathe',
  'briefing',
  'broken',
  'brother',
  'browser',
  'bucket',
  'budget',
  'building',
  'bulb',
  'bulge',
  'bumpy',
  'bundle',
  'burden',
  'burning',
  'busy',
  'buyer',
  'cage',
  'calcium',
  'camera',
  'campus',
  'canyon',
  'capacity',
  'capital',
  'capture',
  'carbon',
  'cards',
  'careful',
  'cargo',
  'carpet',
  'carve',
  'category',
  'cause',
  'ceiling',
  'center',
  'ceramic',
  'champion',
  'change',
  'charity',
  'check',
  'chemical',
  'chest',
  'chew',
  'chubby',
  'cinema',
  'civil',
  'class',
  'clay',
  'cleanup',
  'client',
  'climate',
  'clinic',
  'clock',
  'clogs',
  'closet',
  'clothes',
  'club',
  'cluster',
  'coal',
  'coastal',
  'coding',
  'column',
  'company',
  'corner',
  'costume',
  'counter',
  'course',
  'cover',
  'cowboy',
  'cradle',
  'craft',
  'crazy',
  'credit',
  'cricket',
  'criminal',
  'crisis',
  'critical',
  'crowd',
  'crucial',
  'crunch',
  'crush',
  'crystal',
  'cubic',
  'cultural',
  'curious',
  'curly',
  'custody',
  'cylinder',
  'daisy',
  'damage',
  'dance',
  'darkness',
  'database',
  'daughter',
  'deadline',
  'deal',
  'debris',
  'debut',
  'decent',
  'decision',
  'declare',
  'decorate',
  'decrease',
  'deliver',
  'demand',
  'density',
  'deny',
  'depart',
  'depend',
  'depict',
  'deploy',
  'describe',
  'desert',
  'desire',
  'desktop',
  'destroy',
  'detailed',
  'detect',
  'device',
  'devote',
  'diagnose',
  'dictate',
  'diet',
  'dilemma',
  'diminish',
  'dining',
  'diploma',
  'disaster',
  'discuss',
  'disease',
  'dish',
  'dismiss',
  'display',
  'distance',
  'dive',
  'divorce',
  'document',
  'domain',
  'domestic',
  'dominant',
  'dough',
  'downtown',
  'dragon',
  'dramatic',
  'dream',
  'dress',
  'drift',
  'drink',
  'drove',
  'drug',
  'dryer',
  'duckling',
  'duke',
  'duration',
  'dwarf',
  'dynamic',
  'early',
  'earth',
  'easel',
  'easy',
  'echo',
  'eclipse',
  'ecology',
  'edge',
  'editor',
  'educate',
  'either',
  'elbow',
  'elder',
  'election',
  'elegant',
  'element',
  'elephant',
  'elevator',
  'elite',
  'else',
  'email',
  'emerald',
  'emission',
  'emperor',
  'emphasis',
  'employer',
  'empty',
  'ending',
  'endless',
  'endorse',
  'enemy',
  'energy',
  'enforce',
  'engage',
  'enjoy',
  'enlarge',
  'entrance',
  'envelope',
  'envy',
  'epidemic',
  'episode',
  'equation',
  'equip',
  'eraser',
  'erode',
  'escape',
  'estate',
  'estimate',
  'evaluate',
  'evening',
  'evidence',
  'evil',
  'evoke',
  'exact',
  'example',
  'exceed',
  'exchange',
  'exclude',
  'excuse',
  'execute',
  'exercise',
  'exhaust',
  'exotic',
  'expand',
  'expect',
  'explain',
  'express',
  'extend',
  'extra',
  'eyebrow',
  'facility',
  'fact',
  'failure',
  'faint',
  'fake',
  'false',
  'family',
  'famous',
  'fancy',
  'fangs',
  'fantasy',
  'fatal',
  'fatigue',
  'favorite',
  'fawn',
  'fiber',
  'fiction',
  'filter',
  'finance',
  'findings',
  'finger',
  'firefly',
  'firm',
  'fiscal',
  'fishing',
  'fitness',
  'flame',
  'flash',
  'flavor',
  'flea',
  'flexible',
  'flip',
  'float',
  'floral',
  'fluff',
  'focus',
  'forbid',
  'force',
  'forecast',
  'forget',
  'formal',
  'fortune',
  'forward',
  'founder',
  'fraction',
  'fragment',
  'frequent',
  'freshman',
  'friar',
  'fridge',
  'friendly',
  'frost',
  'froth',
  'frozen',
  'fumes',
  'funding',
  'furl',
  'fused',
  'galaxy',
  'game',
  'garbage',
  'garden',
  'garlic',
  'gasoline',
  'gather',
  'general',
  'genius',
  'genre',
  'genuine',
  'geology',
  'gesture',
  'glad',
  'glance',
  'glasses',
  'glen',
  'glimpse',
  'goat',
  'golden',
  'graduate',
  'grant',
  'grasp',
  'gravity',
  'gray',
  'greatest',
  'grief',
  'grill',
  'grin',
  'grocery',
  'gross',
  'group',
  'grownup',
  'grumpy',
  'guard',
  'guest',
  'guilt',
  'guitar',
  'gums',
  'hairy',
  'hamster',
  'hand',
  'hanger',
  'harvest',
  'have',
  'havoc',
  'hawk',
  'hazard',
  'headset',
  'health',
  'hearing',
  'heat',
  'helpful',
  'herald',
  'herd',
  'hesitate',
  'hobo',
  'holiday',
  'holy',
  'home',
  'hormone',
  'hospital',
  'hour',
  'huge',
  'human',
  'humidity',
  'hunting',
  'husband',
  'hush',
  'husky',
  'hybrid',
  'idea',
  'identify',
  'idle',
  'image',
  'impact',
  'imply',
  'improve',
  'impulse',
  'include',
  'income',
  'increase',
  'index',
  'indicate',
  'industry',
  'infant',
  'inform',
  'inherit',
  'injury',
  'inmate',
  'insect',
  'inside',
  'install',
  'intend',
  'intimate',
  'invasion',
  'involve',
  'iris',
  'island',
  'isolate',
  'item',
  'ivory',
  'jacket',
  'jerky',
  'jewelry',
  'join',
  'judicial',
  'juice',
  'jump',
  'junction',
  'junior',
  'junk',
  'jury',
  'justice',
  'kernel',
  'keyboard',
  'kidney',
  'kind',
  'kitchen',
  'knife',
  'knit',
  'laden',
  'ladle',
  'ladybug',
  'lair',
  'lamp',
  'language',
  'large',
  'laser',
  'laundry',
  'lawsuit',
  'leader',
  'leaf',
  'learn',
  'leaves',
  'lecture',
  'legal',
  'legend',
  'legs',
  'lend',
  'length',
  'level',
  'liberty',
  'library',
  'license',
  'lift',
  'likely',
  'lilac',
  'lily',
  'lips',
  'liquid',
  'listen',
  'literary',
  'living',
  'lizard',
  'loan',
  'lobe',
  'location',
  'losing',
  'loud',
  'loyalty',
  'luck',
  'lunar',
  'lunch',
  'lungs',
  'luxury',
  'lying',
  'lyrics',
  'machine',
  'magazine',
  'maiden',
  'mailman',
  'main',
  'makeup',
  'making',
  'mama',
  'manager',
  'mandate',
  'mansion',
  'manual',
  'marathon',
  'march',
  'market',
  'marvel',
  'mason',
  'material',
  'math',
  'maximum',
  'mayor',
  'meaning',
  'medal',
  'medical',
  'member',
  'memory',
  'mental',
  'merchant',
  'merit',
  'method',
  'metric',
  'midst',
  'mild',
  'military',
  'mineral',
  'minister',
  'miracle',
  'mixed',
  'mixture',
  'mobile',
  'modern',
  'modify',
  'moisture',
  'moment',
  'morning',
  'mortgage',
  'mother',
  'mountain',
  'mouse',
  'move',
  'much',
  'mule',
  'multiple',
  'muscle',
  'museum',
  'music',
  'mustang',
  'nail',
  'national',
  'necklace',
  'negative',
  'nervous',
  'network',
  'news',
  'nuclear',
  'numb',
  'numerous',
  'nylon',
  'oasis',
  'obesity',
  'object',
  'observe',
  'obtain',
  'ocean',
  'often',
  'olympic',
  'omit',
  'oral',
  'orange',
  'orbit',
  'order',
  'ordinary',
  'organize',
  'ounce',
  'oven',
  'overall',
  'owner',
  'paces',
  'pacific',
  'package',
  'paid',
  'painting',
  'pajamas',
  'pancake',
  'pants',
  'papa',
  'paper',
  'parcel',
  'parking',
  'party',
  'patent',
  'patrol',
  'payment',
  'payroll',
  'peaceful',
  'peanut',
  'peasant',
  'pecan',
  'penalty',
  'pencil',
  'percent',
  'perfect',
  'permit',
  'petition',
  'phantom',
  'pharmacy',
  'photo',
  'phrase',
  'physics',
  'pickup',
  'picture',
  'piece',
  'pile',
  'pink',
  'pipeline',
  'pistol',
  'pitch',
  'plains',
  'plan',
  'plastic',
  'platform',
  'playoff',
  'pleasure',
  'plot',
  'plunge',
  'practice',
  'prayer',
  'preach',
  'predator',
  'pregnant',
  'premium',
  'prepare',
  'presence',
  'prevent',
  'priest',
  'primary',
  'priority',
  'prisoner',
  'privacy',
  'prize',
  'problem',
  'process',
  'profile',
  'program',
  'promise',
  'prospect',
  'provide',
  'prune',
  'public',
  'pulse',
  'pumps',
  'punish',
  'puny',
  'pupal',
  'purchase',
  'purple',
  'python',
  'quantity',
  'quarter',
  'quick',
  'quiet',
  'race',
  'racism',
  'radar',
  'railroad',
  'rainbow',
  'raisin',
  'random',
  'ranked',
  'rapids',
  'raspy',
  'reaction',
  'realize',
  'rebound',
  'rebuild',
  'recall',
  'receiver',
  'recover',
  'regret',
  'regular',
  'reject',
  'relate',
  'remember',
  'remind',
  'remove',
  'render',
  'repair',
  'repeat',
  'replace',
  'require',
  'rescue',
  'research',
  'resident',
  'response',
  'result',
  'retailer',
  'retreat',
  'reunion',
  'revenue',
  'review',
  'reward',
  'rhyme',
  'rhythm',
  'rich',
  'rival',
  'river',
  'robin',
  'rocky',
  'romantic',
  'romp',
  'roster',
  'round',
  'royal',
  'ruin',
  'ruler',
  'rumor',
  'sack',
  'safari',
  'salary',
  'salon',
  'salt',
  'satisfy',
  'satoshi',
  'saver',
  'says',
  'scandal',
  'scared',
  'scatter',
  'scene',
  'scholar',
  'science',
  'scout',
  'scramble',
  'screw',
  'script',
  'scroll',
  'seafood',
  'season',
  'secret',
  'security',
  'segment',
  'senior',
  'shadow',
  'shaft',
  'shame',
  'shaped',
  'sharp',
  'shelter',
  'sheriff',
  'short',
  'should',
  'shrimp',
  'sidewalk',
  'silent',
  'silver',
  'similar',
  'simple',
  'single',
  'sister',
  'skin',
  'skunk',
  'slap',
  'slavery',
  'sled',
  'slice',
  'slim',
  'slow',
  'slush',
  'smart',
  'smear',
  'smell',
  'smirk',
  'smith',
  'smoking',
  'smug',
  'snake',
  'snapshot',
  'sniff',
  'society',
  'software',
  'soldier',
  'solution',
  'soul',
  'source',
  'space',
  'spark',
  'speak',
  'species',
  'spelling',
  'spend',
  'spew',
  'spider',
  'spill',
  'spine',
  'spirit',
  'spit',
  'spray',
  'sprinkle',
  'square',
  'squeeze',
  'stadium',
  'staff',
  'standard',
  'starting',
  'station',
  'stay',
  'steady',
  'step',
  'stick',
  'stilt',
  'story',
  'strategy',
  'strike',
  'style',
  'subject',
  'submit',
  'sugar',
  'suitable',
  'sunlight',
  'superior',
  'surface',
  'surprise',
  'survive',
  'sweater',
  'swimming',
  'swing',
  'switch',
  'symbolic',
  'sympathy',
  'syndrome',
  'system',
  'tackle',
  'tactics',
  'tadpole',
  'talent',
  'task',
  'taste',
  'taught',
  'taxi',
  'teacher',
  'teammate',
  'teaspoon',
  'temple',
  'tenant',
  'tendency',
  'tension',
  'terminal',
  'testify',
  'texture',
  'thank',
  'that',
  'theater',
  'theory',
  'therapy',
  'thorn',
  'threaten',
  'thumb',
  'thunder',
  'ticket',
  'tidy',
  'timber',
  'timely',
  'ting',
  'tofu',
  'together',
  'tolerate',
  'total',
  'toxic',
  'tracks',
  'traffic',
  'training',
  'transfer',
  'trash',
  'traveler',
  'treat',
  'trend',
  'trial',
  'tricycle',
  'trip',
  'triumph',
  'trouble',
  'true',
  'trust',
  'twice',
  'twin',
  'type',
  'typical',
  'ugly',
  'ultimate',
  'umbrella',
  'uncover',
  'undergo',
  'unfair',
  'unfold',
  'unhappy',
  'union',
  'universe',
  'unkind',
  'unknown',
  'unusual',
  'unwrap',
  'upgrade',
  'upstairs',
  'username',
  'usher',
  'usual',
  'valid',
  'valuable',
  'vampire',
  'vanish',
  'various',
  'vegan',
  'velvet',
  'venture',
  'verdict',
  'verify',
  'very',
  'veteran',
  'vexed',
  'victim',
  'video',
  'view',
  'vintage',
  'violence',
  'viral',
  'visitor',
  'visual',
  'vitamins',
  'vocal',
  'voice',
  'volume',
  'voter',
  'voting',
  'walnut',
  'warmth',
  'warn',
  'watch',
  'wavy',
  'wealthy',
  'weapon',
  'webcam',
  'welcome',
  'welfare',
  'western',
  'width',
  'wildlife',
  'window',
  'wine',
  'wireless',
  'wisdom',
  'withdraw',
  'wits',
  'wolf',
  'woman',
  'work',
  'worthy',
  'wrap',
  'wrist',
  'writing',
  'wrote',
  'year',
  'yelp',
  'yield',
  'yoga',
  'zero',
];

final _wordListMap = _wordList.asMap().map((idx, word) => MapEntry(word, idx));
