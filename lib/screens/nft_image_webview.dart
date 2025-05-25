import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/screens/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class NFTImageWebview extends StatefulWidget {
  final String imageUrl;
  const NFTImageWebview({
    super.key,
    required this.imageUrl,
  });

  @override
  State<NFTImageWebview> createState() => _NFTImageWebviewState();
}

class _NFTImageWebviewState extends State<NFTImageWebview> {
  String? mimeType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectMimeType();
  }

  Future<void> _detectMimeType() async {
    try {
      final response = await http.head(Uri.parse(widget.imageUrl));
      if (!mounted) return; // ✅ Always check before any setState

      if (response.statusCode == 200) {
        setState(() {
          mimeType = response.headers['content-type'];
          isLoading = false;
        });
      } else {
        setState(() {
          mimeType = 'unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return; // ✅ Check again before calling setState
      setState(() {
        mimeType = 'error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Loader(color: appPrimaryColor),
      );
    }

    if (mimeType != null && mimeType!.contains('svg')) {
      return SvgPicture.network(
        widget.imageUrl,
        semanticsLabel: 'Svg Image',
        placeholderBuilder: (BuildContext context) => const Center(
          child: Loader(color: appPrimaryColor),
        ),
      );
    }

    if (mimeType != null && mimeType!.startsWith('video/')) {
      return VideoPlayerWidget(url: widget.imageUrl);
    }

    // Fallback to raster image (jpg, png, etc.)
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: double.infinity,
      height: 150,
      placeholder: (context, url) => const Center(
        child: Loader(color: appPrimaryColor),
      ),
      errorWidget: (context, url, error) =>
          VideoPlayerWidget(url: widget.imageUrl),
      fit: BoxFit.cover,
    );
  }
}
