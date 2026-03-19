// ─── bech32m helpers ──────────────────────────────────────────────────────────
// Self-contained bech32m encoder (BIP350).
// Differs from bech32 (BIP173) only in the checksum constant: 0x2bc830a3.
// We implement it directly to avoid relying on the bech32 package exporting
// a `bech32m` instance, which older versions do not.

const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _bech32mConst = 0x2bc830a3;

int _bech32mPolymod(List<int> values) {
  const gen = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
  int chk = 1;
  for (final v in values) {
    final b = chk >> 25;
    chk = ((chk & 0x1ffffff) << 5) ^ v;
    for (int i = 0; i < 5; i++) {
      if ((b >> i) & 1 == 1) chk ^= gen[i];
    }
  }
  return chk;
}

List<int> _hrpExpand(String hrp) {
  final result = <int>[];
  for (final c in hrp.codeUnits) result.add(c >> 5);
  result.add(0);
  for (final c in hrp.codeUnits) result.add(c & 31);
  return result;
}

String bech32mEncode(String hrp, List<int> data) {
  final combined = [...data, 0, 0, 0, 0, 0, 0];
  final polymod =
      _bech32mPolymod([..._hrpExpand(hrp), ...combined]) ^ _bech32mConst;
  for (int i = 0; i < 6; i++) {
    combined[data.length + i] = (polymod >> (5 * (5 - i))) & 31;
  }
  return '${hrp}1${combined.map((d) => _charset[d]).join()}';
}
