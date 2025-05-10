import 'package:cached_network_image/cached_network_image.dart';
import 'package:cryptowallet/components/loader.dart';
import 'package:cryptowallet/screens/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as p;
import '../utils/app_config.dart';

class NFTImageWebview extends StatefulWidget {
  final String imageUrl;
  const NFTImageWebview({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);
  @override
  State<NFTImageWebview> createState() => _NFTImageWebviewState();
}

class _NFTImageWebviewState extends State<NFTImageWebview> {
  final browserController = TextEditingController();

  ValueNotifier loadingPercent = ValueNotifier<double>(0);
  bool isSvg = false;

  @override
  initState() {
    final extension = p.extension(widget.imageUrl);
    isSvg = extension == '.svg';

    super.initState();
  }

  @override
  void dispose() {
    browserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isSvg) {
      return SvgPicture.network(
        widget.imageUrl,
        semanticsLabel: 'Svg Image',
        placeholderBuilder: (BuildContext context) => const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Loader(
                color: appPrimaryColor,
              ),
            )
          ],
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: double.infinity,
      height: 150,
      placeholder: (context, url) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Loader(
              color: appPrimaryColor,
            ),
          )
        ],
      ),
      errorWidget: (context, url, error) {
        return VideoPlayer(
          url: widget.imageUrl,
        );
      },
      fit: BoxFit.cover,
    );
  }
}
