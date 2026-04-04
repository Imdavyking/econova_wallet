import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/nimiq_identicon.dart';
// ignore: depend_on_referenced_packages
import 'package:xml/xml.dart';

class NimiqIdenticonWidget extends StatelessWidget {
  final String address;
  final double size;

  // Cache parsed XML document — shared across all instances
  static XmlDocument? _parsedSprite;

  const NimiqIdenticonWidget({
    required this.address,
    this.size = 64,
    super.key,
  });

  static const _shadow =
      'M119.21,80a39.46,39.46,0,0,1-67.13,28.13c10.36,2.33,36,3,49.82-14.28,10.39-12.47,8.31-33.23,4.16-43.26A39.35,39.35,0,0,1,119.21,80Z';

  String _buildSvg() {
    _parsedSprite ??= XmlDocument.parse(nimiqSpriteSvg);
    final o = NimiqIdenticon.fromAddress(address);

    String id(String prefix, int idx) =>
        '${prefix}_${(idx + 1).toString().padLeft(2, '0')}';

    String getSymbol(String symbolId) {
      final match = _parsedSprite!.findAllElements('symbol').firstWhere(
          (e) => e.getAttribute('id') == symbolId,
          orElse: () => throw StateError('Symbol $symbolId not found'));
      return match.children
          .map((c) => c.toXmlString())
          .join()
          .replaceAll('currentColor', o.bodyColor);
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160">
  <g color="${o.bodyColor}" fill="${o.accentColor}">
    <circle cx="80" cy="80" r="80" fill="${o.backgroundColor}"/>
    <circle cx="80" cy="80" r="40" fill="${o.bodyColor}"/>
    <g opacity=".1" fill="#010101"><path d="$_shadow"/></g>
    ${getSymbol(id('top', o.top))}
    ${getSymbol(id('side', o.side))}
    ${getSymbol(id('face', o.face))}
    ${getSymbol(id('bottom', o.bottom))}
  </g>
</svg>''';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _buildSvg(),
      width: size,
      height: size,
    );
  }
}
