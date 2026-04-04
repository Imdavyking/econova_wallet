// ignore_for_file: non_constant_identifier_names
// Dart port of https://github.com/appditto/natricon (MIT License)
//
// Algorithm (from the Go server source):
//   1. SHA-256 the address → 64-char hex hash
//   2. Slice the hash into entropy windows to seed independent MT19937 PRNGs
//   3. Use those PRNGs to pick body color, hair color, body/hair/mouth/eye assets
//   4. Assemble the SVG layers with color substitutions
//
// Asset files must be bundled at  assets/natricon/<type>/<file>.svg
// (matching the folder layout from server/assets/illustrations/).
//
// Dependencies (pubspec.yaml):
//   crypto: ^3.0.0       # for SHA-256
//   flutter_svg: ^2.0.0  # to render the assembled SVG

import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── MT19937 (32-bit Mersenne Twister) ────────────────────────────────────────
// Direct port of server/rand/mt19937.go

class _MT19937 {
  static const int _n = 624;
  static const int _m = 397;
  static const int _matrixA = 0x9908b0df;
  static const int _upperMask = 0x80000000;
  static const int _lowerMask = 0x7fffffff;

  final List<int> _mt = List.filled(_n, 0); // uint32 stored as int
  int _mti = _n + 1;

  void seed(int s) {
    // s is treated as uint32
    s = s & 0xFFFFFFFF;
    _mt[0] = s;
    for (_mti = 1; _mti < _n; _mti++) {
      int prev = _mt[_mti - 1];
      int hi = (prev ^ (prev >> 30)) & 0xFFFF0000;
      int lo = (prev ^ (prev >> 30)) & 0x0000FFFF;
      _mt[_mti] = (((hi >> 16) * 1812433253) << 16) + (lo * 1812433253) + _mti;
      _mt[_mti] &= 0xFFFFFFFF;
    }
  }

  int uint32() {
    int y;
    const mag01 = [0, _matrixA];

    if (_mti >= _n) {
      if (_mti == _n + 1) seed(5489);

      int kk;
      for (kk = 0; kk < _n - _m; kk++) {
        y = (_mt[kk] & _upperMask) | (_mt[kk + 1] & _lowerMask);
        _mt[kk] = _mt[kk + _m] ^ (y >> 1) ^ mag01[y & 1];
      }
      for (; kk < _n - 1; kk++) {
        y = (_mt[kk] & _upperMask) | (_mt[kk + 1] & _lowerMask);
        _mt[kk] = _mt[kk + (_m - _n)] ^ (y >> 1) ^ mag01[y & 1];
      }
      y = (_mt[_n - 1] & _upperMask) | (_mt[0] & _lowerMask);
      _mt[_n - 1] = _mt[_m - 1] ^ (y >> 1) ^ mag01[y & 1];
      _mti = 0;
    }

    y = _mt[_mti++];
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9D2C5680;
    y ^= (y << 15) & 0xEFC60000;
    y ^= (y >> 18);
    return y & 0xFFFFFFFF;
  }

  /// Generates a random int in [0, n) using Lemire's method.
  /// Matches Go's Int31n exactly.
  int int31n(int n) {
    assert(n > 0);
    int v = uint32();
    int prod = v * n; // may overflow int64 in theory but Dart uses 64-bit ints
    int low = prod & 0xFFFFFFFF;
    if (low < n) {
      // thresh = (2^32 - n) % n  →  (-n as uint32) % n
      int thresh = ((-n) & 0xFFFFFFFF) % n;
      while (low < thresh) {
        v = uint32();
        prod = v * n;
        low = prod & 0xFFFFFFFF;
      }
    }
    return prod >> 32;
  }
}

// ── Color math ────────────────────────────────────────────────────────────────
// Port of server/color/color.go

const double _redPB = 0.241;
const double _greenPB = 0.691;
const double _bluePB = 0.068;

class _RGB {
  final double r, g, b;
  const _RGB(this.r, this.g, this.b);

  double get perceivedBrightness255 =>
      math.sqrt(_redPB * r * r + _greenPB * g * g + _bluePB * b * b);

  double get perceivedBrightness => perceivedBrightness255 / 255 * 100;

  // Nudge to match Go's byte(x + 1/512) truncation
  static const double _delta = 1 / 512.0;

  String toHtml() {
    int ri = (r + _delta).toInt().clamp(0, 255);
    int gi = (g + _delta).toInt().clamp(0, 255);
    int bi = (b + _delta).toInt().clamp(0, 255);
    return '#${ri.toRadixString(16).padLeft(2, '0')}'
        '${gi.toRadixString(16).padLeft(2, '0')}'
        '${bi.toRadixString(16).padLeft(2, '0')}';
  }

  _HSB toHSB() {
    double mn = math.min(math.min(r, g), b);
    double mx = math.max(math.max(r, g), b);
    double delta = mx - mn;
    double h = 0, s = 0, v = 0;
    if (mx != 0) {
      s = delta / mx;
      v = mx / 255;
    }
    if (delta != 0) {
      if (r == mx) {
        h = (g - b) / delta;
      } else if (g == mx) {
        h = 2.0 + (b - r) / delta;
      } else {
        h = 4.0 + (r - g) / delta;
      }
    }
    h *= 60;
    if (h < 0) h += 360;
    return _HSB(h, s, v);
  }

  static _RGB fromHtml(String hex) {
    if (hex.startsWith('#')) hex = hex.substring(1);
    int r = int.parse(hex.substring(0, 2), radix: 16);
    int g = int.parse(hex.substring(2, 4), radix: 16);
    int b = int.parse(hex.substring(4, 6), radix: 16);
    return _RGB(r.toDouble(), g.toDouble(), b.toDouble());
  }
}

class _HSB {
  final double h, s, b;
  const _HSB(this.h, this.s, this.b);

  _RGB toRGB() {
    double hp = h / 60.0;
    double c = b * s;
    double x = c * (1.0 - (hp % 2.0 - 1.0).abs());
    double m = b - c;
    double r = 0, g = 0, bl = 0;
    if (hp < 1) {
      r = c;
      g = x;
    } else if (hp < 2) {
      r = x;
      g = c;
    } else if (hp < 3) {
      g = c;
      bl = x;
    } else if (hp < 4) {
      g = x;
      bl = c;
    } else if (hp < 5) {
      r = x;
      bl = c;
    } else {
      r = c;
      bl = x;
    }
    return _RGB(255 * (m + r), 255 * (m + g), 255 * (m + bl));
  }
}

// ── Color picker ──────────────────────────────────────────────────────────────
// Port of server/image/color_picker.go

const double _minPB = 18.0;
const double _maxPB = 95.0;
const double _minPB255 = _minPB / 100 * 255;
const double _maxPB255 = _maxPB / 100 * 255;
const double _bodyHairHueDist = 90.0;
const double _minTotalSat = 60.0;
const double _minTotalBrightness = 130.0;
const double _minHairBrightness = 40.0;
const double _minShadowOpacity = 0.075;
const double _maxShadowOpacity = 0.4;
const double _minBlk29Opacity = 0.2;
const double _maxBlk29Opacity = 0.5;
const int _lightDarkSwitch = 30;
const double _hairBrightDynMax = 90.0;
const double _hairSatDynMin = 10.0;

/// Seed an MT19937 from a hex substring (parsed as int64, lower 32 bits used).
int _parseSeed(String hexStr) {
  return int.parse(hexStr, radix: 16) & 0xFFFFFFFF;
}

_RGB _getBodyColor(String entropy16) {
  // R
  final r = _MT19937()..seed(_parseSeed(entropy16.substring(0, 4)));
  double R = r.int31n(255 * 1000) / 1000.0;

  // G
  final rG = _MT19937()..seed(_parseSeed(entropy16.substring(4, 8)));
  double G = rG.int31n(255 * 1000) / 1000.0;

  // B — constrained so perceived brightness stays in [_minPB, _maxPB]
  double lowerBound = math.max(
          math.sqrt(math.max(
              (_minPB255 * _minPB255 - _redPB * R * R - _greenPB * G * G) /
                  _bluePB,
              0.0)),
          0.0) *
      1000;
  double upperBound = math.min(
          math.sqrt(math.max(
              (_maxPB255 * _maxPB255 - _redPB * R * R - _greenPB * G * G) /
                  _bluePB,
              0.0)),
          255.0) *
      1000;
  final rB = _MT19937()..seed(_parseSeed(entropy16.substring(8, 12)));
  double B =
      (rB.int31n((upperBound - lowerBound).toInt()) + lowerBound) / 1000.0;

  return _RGB(R, G, B);
}

_RGB _getHairColor(
    _RGB body, String hEntropy, String sEntropy, String bEntropy) {
  final hsb = body.toHSB();

  // Hue: shift body hue by 180 ± BodyHairHueDist
  final rH = _MT19937()..seed(_parseSeed(hEntropy));
  double lowerH = hsb.h - 180 - _bodyHairHueDist;
  double upperH = hsb.h - 180 + _bodyHairHueDist;
  double H =
      (rH.int31n((upperH * 1000 - lowerH * 1000).toInt()) + lowerH * 1000) /
          1000.0;
  if (H < 0) H += 360;

  // Saturation
  final rS = _MT19937()..seed(_parseSeed(sEntropy));
  int lowerSBound = math.max(_minTotalSat - hsb.s * 100.0, 0.0).toInt() * 1000;
  double S =
      (rS.int31n(100 * 1000 - lowerSBound) + lowerSBound) / (100.0 * 1000.0);

  // Brightness
  final rB = _MT19937()..seed(_parseSeed(bEntropy));
  double upperBBound = _hairBrightDynMax;
  if (S * 100 > _hairSatDynMin) upperBBound = 100.0;
  double lowerBBound = math.min(
      math.max(_minTotalBrightness - hsb.b * 100.0, _minHairBrightness),
      upperBBound);
  upperBBound *= 1000;
  lowerBBound *= 1000;
  double B = (rB.int31n((upperBBound - lowerBBound).toInt()) + lowerBBound) /
      (100.0 * 1000.0);

  return _HSB(H, S, B).toRGB();
}

double _targetOpacity(_RGB c) =>
    _minShadowOpacity +
    (1 - c.perceivedBrightness / 100) * (_maxShadowOpacity - _minShadowOpacity);

double _blk29Opacity(_RGB c) =>
    _minBlk29Opacity +
    (1 - c.perceivedBrightness / 100) * (_maxBlk29Opacity - _minBlk29Opacity);

// ── Asset model ───────────────────────────────────────────────────────────────

enum _Sex { male, female, neutral }

enum _IllType {
  body,
  bodyOutline,
  hairFront,
  hairBack,
  hairOutline,
  mouth,
  mouthOutline,
  eye
}

class _Asset {
  final String fileName;
  final _IllType type;
  final _Sex sex;
  final bool bodyColored; // replace #00FFFF with body color
  final bool hairColored; // replace #FF0000 with hair color
  final bool lightOnly; // only usable when brightness >= _lightDarkSwitch
  final bool darkColored; // swap black→white when dark background
  final bool darkBWColored; // swap white→grey when dark background
  final bool blk299; // dynamic opacity for fill-opacity="0.299"
  String svgContents;

  _Asset({
    required this.fileName,
    required this.type,
    this.sex = _Sex.neutral,
    this.bodyColored = false,
    this.hairColored = false,
    this.lightOnly = false,
    this.darkColored = false,
    this.darkBWColored = false,
    this.blk299 = false,
    this.svgContents = '',
  });

  /// Parse numeric prefix from filename, e.g. "14_f.svg" → 14
  int get numericId {
    final part = fileName.split('_').first.split('.').first;
    return int.tryParse(part) ?? 0;
  }
}

// ── Asset manager ─────────────────────────────────────────────────────────────

class _AssetManager {
  final List<_Asset> bodies;
  final List<_Asset> bodyOutlines;
  final List<_Asset> hairFronts;
  final List<_Asset> hairBacks;
  final List<_Asset> hairOutlines;
  final List<_Asset> mouths;
  final List<_Asset> mouthOutlines;
  final List<_Asset> eyes;

  const _AssetManager({
    required this.bodies,
    required this.bodyOutlines,
    required this.hairFronts,
    required this.hairBacks,
    required this.hairOutlines,
    required this.mouths,
    required this.mouthOutlines,
    required this.eyes,
  });

  List<_Asset> hairsForSex(_Sex sex) => sex == _Sex.neutral
      ? hairFronts
      : hairFronts.where((a) => a.sex == sex || a.sex == _Sex.neutral).toList();

  List<_Asset> mouthsForSex(_Sex sex, double brightness) {
    int lum = brightness.toInt();
    return mouths.where((a) {
      if (_lightDarkSwitch > lum && a.lightOnly) return false;
      if (sex == _Sex.neutral) return true;
      return a.sex == sex || a.sex == _Sex.neutral;
    }).toList();
  }

  List<_Asset> eyesForSex(_Sex sex, double brightness) {
    int lum = brightness.toInt();
    return eyes.where((a) {
      if (_lightDarkSwitch > lum && a.lightOnly) return false;
      if (sex == _Sex.neutral) return true;
      return a.sex == sex || a.sex == _Sex.neutral;
    }).toList();
  }
}

// ── Public result type ────────────────────────────────────────────────────────

class NatriconParts {
  final _RGB bodyColor;
  final _RGB hairColor;
  final _Asset bodyAsset;
  final _Asset hairAsset;
  final _Asset? hairBackAsset;
  final _Asset? bodyOutlineAsset;
  final _Asset? hairOutlineAsset;
  final _Asset mouthAsset;
  final _Asset? mouthOutlineAsset;
  final _Asset eyeAsset;

  const NatriconParts({
    required this.bodyColor,
    required this.hairColor,
    required this.bodyAsset,
    required this.hairAsset,
    this.hairBackAsset,
    this.bodyOutlineAsset,
    this.hairOutlineAsset,
    required this.mouthAsset,
    this.mouthOutlineAsset,
    required this.eyeAsset,
  });
}

// ── Core generator ────────────────────────────────────────────────────────────

class NatriconGenerator {
  final _AssetManager _assets;

  NatriconGenerator._(this._assets);

  /// Load all assets from the Flutter asset bundle.
  /// Call once at startup and cache the result.
  static Future<NatriconGenerator> load(
      {String assetBasePath = 'assets/natricon'}) async {
    final bodies = await _loadDir(assetBasePath, 'body', bodyColored: true);
    final bodyOutlines = await _loadDir(assetBasePath, 'body-outline');
    final hairFronts =
        await _loadDir(assetBasePath, 'hair-front', hairColored: true);
    final hairBacks =
        await _loadDir(assetBasePath, 'hair-back', hairColored: true);
    final hairOutlines = await _loadDir(assetBasePath, 'hair-outline');
    final mouths = await _loadDir(assetBasePath, 'mouth', hairColored: true);
    final mouthOutlines = await _loadDir(assetBasePath, 'mouth-outline');
    final eyes = await _loadDir(assetBasePath, 'eyes');

    return NatriconGenerator._(_AssetManager(
      bodies: bodies,
      bodyOutlines: bodyOutlines,
      hairFronts: hairFronts,
      hairBacks: hairBacks,
      hairOutlines: hairOutlines,
      mouths: mouths,
      mouthOutlines: mouthOutlines,
      eyes: eyes,
    ));
  }

  static Future<List<_Asset>> _loadDir(
    String base,
    String folder, {
    bool bodyColored = false,
    bool hairColored = false,
  }) async {
    // Use Flutter's AssetManifest to discover SVG files — no manifest.txt needed.
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final prefix = '$base/$folder/';
    final fileNames = assetManifest
        .listAssets()
        .where((k) => k.startsWith(prefix) && k.endsWith('.svg'))
        .map((k) =>
            k.substring(prefix.length)) // strip path prefix → bare filename
        .toList()
      ..sort(); // deterministic order matching the Go server's filepath.Walk sort

    assert(fileNames.isNotEmpty,
        'No SVG assets found under $prefix — check pubspec.yaml flutter.assets');

    final illType = _illTypeForFolder(folder);
    final assets = <_Asset>[];

    for (final name in fileNames) {
      final sex = _sexFromName(name);
      final lightOnly = _lightOnlyFromName(name);
      final darkColored = name.contains('_lod_b') && !name.contains('_lod_bw');
      final darkBWColored = name.contains('_lod_bw');
      final blk299 = name.contains('_blk29');

      final contents = await rootBundle.loadString('$prefix$name');
      assets.add(_Asset(
        fileName: name,
        type: illType,
        sex: sex,
        bodyColored: bodyColored,
        hairColored: hairColored,
        lightOnly: lightOnly,
        darkColored: darkColored,
        darkBWColored: darkBWColored,
        blk299: blk299,
        svgContents: contents,
      ));
    }
    return assets;
  }

  static _IllType _illTypeForFolder(String folder) {
    switch (folder) {
      case 'body':
        return _IllType.body;
      case 'body-outline':
        return _IllType.bodyOutline;
      case 'hair-front':
        return _IllType.hairFront;
      case 'hair-back':
        return _IllType.hairBack;
      case 'hair-outline':
        return _IllType.hairOutline;
      case 'mouth':
        return _IllType.mouth;
      case 'mouth-outline':
        return _IllType.mouthOutline;
      case 'eyes':
        return _IllType.eye;
      default:
        return _IllType.body;
    }
  }

  static _Sex _sexFromName(String name) {
    if (name.contains('_f')) return _Sex.female;
    if (name.contains('_m')) return _Sex.male;
    return _Sex.neutral;
  }

  static bool _lightOnlyFromName(String name) {
    // From load_files.go: lightOnly = true unless name has _lod or _ld
    return !name.contains('_lod') && !name.contains('_ld');
  }

  // ── Generate from address ────────────────────────────────────────────────

  /// Returns the assembled SVG string for a given Nano address.
  String generateSvg(String address) {
    final parts = _partsForAddress(address);
    return _assembleSvg(parts);
  }

  NatriconParts _partsForAddress(String address) {
    // SHA-256 the address → 64-char hex
    final hashBytes = sha256.convert(utf8.encode(address)).bytes;
    final hash =
        hashBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return _partsForHash(hash);
  }

  NatriconParts _partsForHash(String hash) {
    assert(hash.length == 64);

    // ── Colors ──
    final bodyColor = _getBodyColor(hash.substring(0, 16));
    final hairColor = _getHairColor(
      bodyColor,
      hash.substring(16, 26), // hue entropy (10 chars)
      hash.substring(26, 30), // sat entropy  (4 chars)
      hash.substring(30, 34), // brightness entropy (4 chars)
    );

    // ── Body asset ──
    final bodyAsset = _selectAsset(_assets.bodies, hash.substring(34, 40));

    // ── Hair asset (sex-aware) ──
    final hairOptions = _assets.hairsForSex(bodyAsset.sex);
    final hairAsset = _selectFrom(hairOptions, hash.substring(40, 46));

    // ── Companion assets ──
    final hairBackAsset = _matchByName(_assets.hairBacks, hairAsset.fileName);
    final bodyOutlineAsset =
        _matchByName(_assets.bodyOutlines, bodyAsset.fileName);
    final hairOutlineAsset =
        _matchByName(_assets.hairOutlines, hairAsset.fileName);

    // ── Sex propagation (body → hair → mouth) ──
    _Sex targetSex = _Sex.neutral;
    if (bodyAsset.sex != _Sex.neutral) {
      targetSex = bodyAsset.sex;
    } else if (hairAsset.sex != _Sex.neutral) {
      targetSex = hairAsset.sex;
    }

    final brightness = bodyColor.perceivedBrightness;
    final mouthOptions = _assets.mouthsForSex(targetSex, brightness);
    final mouthAsset = _selectFrom(mouthOptions, hash.substring(46, 55));
    if (targetSex == _Sex.neutral && mouthAsset.sex != _Sex.neutral) {
      targetSex = mouthAsset.sex;
    }

    final eyeOptions = _assets.eyesForSex(targetSex, brightness);
    final eyeAsset = _selectFrom(eyeOptions, hash.substring(55, 64));

    final mouthOutlineAsset =
        _matchByName(_assets.mouthOutlines, mouthAsset.fileName);

    return NatriconParts(
      bodyColor: bodyColor,
      hairColor: hairColor,
      bodyAsset: bodyAsset,
      hairAsset: hairAsset,
      hairBackAsset: hairBackAsset,
      bodyOutlineAsset: bodyOutlineAsset,
      hairOutlineAsset: hairOutlineAsset,
      mouthAsset: mouthAsset,
      mouthOutlineAsset: mouthOutlineAsset,
      eyeAsset: eyeAsset,
    );
  }

  _Asset _selectAsset(List<_Asset> list, String entropy) =>
      _selectFrom(list, entropy);

  _Asset _selectFrom(List<_Asset> list, String entropy) {
    final rng = _MT19937()..seed(_parseSeed(entropy));
    final idx = rng.int31n(list.length);
    return list[idx];
  }

  _Asset? _matchByName(List<_Asset> list, String fileName) {
    for (final a in list) {
      if (a.fileName == fileName) return a;
    }
    return null;
  }

  // ── SVG assembly ──────────────────────────────────────────────────────────
  // Port of server/image/assemble.go  (CombineSVG)

  static const String _bodySwatch = '#00FFFF';
  static const String _hairSwatch = '#FF0000';
  static const String _mouthHairSwatch = '#FFFF00';
  static const String _shadowPlaceholder = 'fill-opacity="0.15"';
  static const String _blk299Placeholder = 'fill-opacity="0.299"';
  static const String _lodBwReplacement = '#9CA2AF';

  String _assembleSvg(NatriconParts p) {
    final int pb = p.bodyColor.perceivedBrightness.toInt();
    final bool isDark = pb < _lightDarkSwitch;
    final double shadow = _targetOpacity(p.bodyColor);
    final double shadowHair = _targetOpacity(p.hairColor);
    final double blk29 = _blk29Opacity(p.bodyColor);
    final String bodyHex = p.bodyColor.toHtml();
    final String hairHex = p.hairColor.toHtml();
    final String opacityStr = shadow.toStringAsFixed(6);
    final String opacityHairStr = shadowHair.toStringAsFixed(6);
    final String blk29Str = blk29.toStringAsFixed(6);

    final buf = StringBuffer();
    buf.write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">');

    // Layer order matches CombineSVG:
    // bodyOutline → mouthOutline → hairOutline → backHair →
    // body → hair → mouth → eye → badge (not handled here)

    void writeGroup(String id, String inner) {
      buf.write('<g id="$id">$inner</g>');
    }

    String _inner(String raw) {
      // Strip outer <svg ...>...</svg> wrapper
      final start = raw.indexOf('>') + 1;
      final end = raw.lastIndexOf('</svg>');
      if (start <= 0 || end <= start) return raw;
      return raw.substring(start, end);
    }

    // Body outline
    if (p.bodyOutlineAsset != null) {
      writeGroup('bodyOutline', _inner(p.bodyOutlineAsset!.svgContents));
    }

    // Mouth outline
    if (p.mouthOutlineAsset != null) {
      writeGroup('mouthOutline', _inner(p.mouthOutlineAsset!.svgContents));
    }

    // Hair outline
    if (p.hairOutlineAsset != null) {
      writeGroup('hairOutline', _inner(p.hairOutlineAsset!.svgContents));
    }

    // Back hair
    if (p.hairBackAsset != null) {
      String doc = _inner(p.hairBackAsset!.svgContents);
      if (p.hairAsset.hairColored) {
        doc = doc.replaceAll(_hairSwatch, hairHex);
        doc = doc.replaceAll(
            _shadowPlaceholder, 'fill-opacity="$opacityHairStr"');
      }
      writeGroup('backhair', doc);
    }

    // Body
    {
      String doc = _inner(p.bodyAsset.svgContents);
      if (p.bodyAsset.bodyColored) {
        doc = doc.replaceAll(_bodySwatch, bodyHex);
        doc = doc.replaceAll(_shadowPlaceholder, 'fill-opacity="$opacityStr"');
      }
      writeGroup('body', doc);
    }

    // Hair front
    {
      String doc = _inner(p.hairAsset.svgContents);
      if (p.hairAsset.hairColored) {
        doc = doc.replaceAll(_hairSwatch, hairHex);
        doc = doc.replaceAll(
            _shadowPlaceholder, 'fill-opacity="$opacityHairStr"');
      }
      writeGroup('hair', doc);
    }

    // Mouth
    {
      String doc = _inner(p.mouthAsset.svgContents);
      if (p.hairAsset.hairColored) {
        doc = doc.replaceAll(_mouthHairSwatch, hairHex);
        doc = doc.replaceAll(
            _shadowPlaceholder, 'fill-opacity="$opacityHairStr"');
      }
      if (isDark && p.mouthAsset.darkBWColored) {
        doc = doc.replaceAll('white', _lodBwReplacement);
      }
      if (isDark && p.mouthAsset.darkColored) {
        doc = doc.replaceAll('black', 'white');
      } else if (!isDark && p.mouthAsset.blk299) {
        doc = doc.replaceAll(_blk299Placeholder, 'fill-opacity="$blk29Str"');
      }
      writeGroup('mouth', doc);
    }

    // Eyes
    {
      String doc = _inner(p.eyeAsset.svgContents);
      if (isDark && p.eyeAsset.darkBWColored) {
        doc = doc.replaceAll('white', _lodBwReplacement);
      }
      if (isDark && p.eyeAsset.darkColored) {
        doc = doc.replaceAll('black', 'white');
      } else if (!isDark && p.eyeAsset.blk299) {
        doc = doc.replaceAll(_blk299Placeholder, 'fill-opacity="$blk29Str"');
      }
      writeGroup('eye', doc);
    }

    buf.write('</svg>');
    return buf.toString();
  }
}

// ── Flutter widget ────────────────────────────────────────────────────────────

/// Displays a Natricon for a given Nano address.
///
/// Usage:
///   final generator = await NatriconGenerator.load();
///   NatriconWidget(address: 'nano_1abc...', generator: generator, size: 64)
///
/// Or use the lazy-loading constructor which handles the future internally.
class NatriconWidget extends StatelessWidget {
  final String address;
  final double size;
  final NatriconGenerator? generator;

  const NatriconWidget({
    required this.address,
    this.size = 64,
    this.generator,
    super.key,
  });

  // ── Lazy singleton ───────────────────────────────────────────────────────

  static NatriconGenerator? _cached;
  static Future<NatriconGenerator>? _loadFuture;

  static Future<NatriconGenerator> _ensureLoaded() {
    if (_cached != null) return Future.value(_cached);
    _loadFuture ??= NatriconGenerator.load().then((g) {
      _cached = g;
      _loadFuture = null;
      return g;
    }).catchError((Object e, StackTrace st) {
      _loadFuture = null;
      debugPrint('[NatriconWidget] Failed to load assets: $e\n$st');
      throw e;
    });
    return _loadFuture!;
  }

  static Future<void> preload() => _ensureLoaded();

  @override
  Widget build(BuildContext context) {
    final gen = generator ?? _cached;
    if (gen != null) return _render(gen);

    return FutureBuilder<NatriconGenerator>(
      future: _ensureLoaded(),
      builder: (_, snap) {
        if (snap.hasError) {
          debugPrint(
              '[NatriconWidget] Error: ${snap.error}\n${snap.stackTrace}');
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: Icon(Icons.broken_image, size: 24)),
          );
        }
        if (!snap.hasData) {
          return SizedBox(
            width: size,
            height: size,
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _render(snap.data!);
      },
    );
  }

  Widget _render(NatriconGenerator gen) {
    final svg = gen.generateSvg(address);
    return SvgPicture.string(svg, width: size, height: size);
  }
}
