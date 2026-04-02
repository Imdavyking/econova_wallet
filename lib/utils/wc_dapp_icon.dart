import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

/// Shared widget for rendering a dApp's icon with loading/error states.
/// Replaces the repeated CachedNetworkImage + Loader + errorWidget pattern
/// across all WalletConnect connectors and preview screens.
class WCDappIcon extends StatelessWidget {
  final String? iconUrl;
  final double size;

  const WCDappIcon({
    super.key,
    this.iconUrl,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: ipfsTohttp(iconUrl!),
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: Loader(color: appPrimaryColor),
          ),
        ),
        errorWidget: (_, __, ___) => const Icon(
          Icons.error,
          color: Colors.red,
        ),
      ),
    );
  }
}
