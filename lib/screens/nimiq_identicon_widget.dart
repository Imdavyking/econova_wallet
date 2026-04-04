import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_app/screens/nimiq_identicon.dart';
import 'package:xml/xml.dart';

class NimiqIdenticonWidget extends StatefulWidget {
  final String address;
  final double size;

  const NimiqIdenticonWidget({
    required this.address,
    this.size = 64,
    super.key,
  });

  @override
  State<NimiqIdenticonWidget> createState() => _NimiqIdenticonWidgetState();
}

class _NimiqIdenticonWidgetState extends State<NimiqIdenticonWidget> {
  String? _svgData;
  static String? _cachedSprite; // shared across all instances
  @override
  void initState() {
    super.initState();
    _buildSvg();
  }

  Future<void> _buildSvg() async {
    _cachedSprite ??= await rootBundle.loadString('assets/identicons.min.svg');
    final options = NimiqIdenticon.fromAddress(widget.address);

    // Debug: check if currentColor exists in the sprite at all
    debugPrint(
        'sprite has currentColor: ${_cachedSprite!.contains('currentColor')}');

    final svg = _composeSvg(_cachedSprite!, options);

    // Debug: print the final composed SVG
    _printFull('composed SVG:\n$svg');

    setState(() => _svgData = svg);
  }

  void _printFull(String text) {
    const chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      debugPrint(text.substring(
          i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }

  String _composeSvg(String sprite, NimiqIconOptions o) {
    final doc = XmlDocument.parse(sprite); // parse once

    String id(String prefix, int zeroBasedIndex) {
      final n = (zeroBasedIndex + 1).toString().padLeft(2, '0');
      return '${prefix}_$n';
    }

    String getSymbol(String symbolId) {
      final matches = doc
          .findAllElements('symbol')
          .where((e) => e.getAttribute('id') == symbolId)
          .toList();
      if (matches.isEmpty) throw StateError('Symbol "$symbolId" not found.');
      return matches.first.children
          .map((c) => c.toXmlString())
          .join()
          .replaceAll(
              'currentColor', o.bodyColor); // currentColor = body, NOT accent
    }

    const shadow =
        'M119.21,80a39.46,39.46,0,0,1-67.13,28.13c10.36,2.33,36,3,49.82-14.28,10.39-12.47,8.31-33.23,4.16-43.26A39.35,39.35,0,0,1,119.21,80Z';

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160">
  <g color="${o.bodyColor}" fill="${o.accentColor}">
    <circle cx="80" cy="80" r="80" fill="${o.backgroundColor}"/>
    <circle cx="80" cy="80" r="40" fill="${o.bodyColor}"/>
    <g opacity=".1" fill="#010101"><path d="$shadow"/></g>
    ${getSymbol(id('top', o.top))}
    ${getSymbol(id('side', o.side))}
    ${getSymbol(id('face', o.face))}
    ${getSymbol(id('bottom', o.bottom))}
  </g>
</svg>''';
  }

  @override
  Widget build(BuildContext context) {
    if (_svgData == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(),
      );
    }
    return SvgPicture.string(
      _svgData!,
      width: widget.size,
      height: widget.size,
    );
  }
}
