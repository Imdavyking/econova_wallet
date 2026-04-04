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
    debugPrint('composed SVG:\n$svg');

    setState(() => _svgData = svg);
  }

  String _composeSvg(String sprite, NimiqIconOptions o) {
    // IDs in the SVG are 1-based and zero-padded: face_01, face_02, …
    String id(String prefix, int zeroBasedIndex) {
      final n = (zeroBasedIndex + 1).toString().padLeft(2, '0');
      return '${prefix}_$n';
    }

    String getSymbol(String symbolId) {
      final doc = XmlDocument.parse(sprite);
      final matches = doc
          .findAllElements('symbol')
          .where((e) => e.getAttribute('id') == symbolId)
          .toList();

      if (matches.isEmpty) {
        throw StateError('Symbol "$symbolId" not found in sprite.');
      }

      final content = matches.first.children.map((c) => c.toXmlString()).join();
      return content.replaceAll(
          'currentColor', o.accentColor); // ← this is the real fix
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160">
  <circle cx="80" cy="80" r="80" fill="${o.backgroundColor}"/>
  <g fill="${o.bodyColor}">${getSymbol(id('face', o.face))}</g>
  <g fill="${o.bodyColor}">${getSymbol(id('top', o.top))}</g>
  <g fill="${o.bodyColor}">${getSymbol(id('side', o.side))}</g>
  <g fill="${o.bodyColor}">${getSymbol(id('bottom', o.bottom))}</g>
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
