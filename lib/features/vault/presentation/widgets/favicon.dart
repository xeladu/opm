import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Favicon extends StatefulWidget {
  final String url;

  const Favicon({super.key, required this.url});

  @override
  State<Favicon> createState() => _State();
}

class _State extends State<Favicon> {
  @override
  Widget build(BuildContext context) {
    final faviconUrl = _getFaviconUrl();

    // If we couldn't construct a favicon URL, show a stable placeholder.
    if (faviconUrl.isEmpty) {
      return Icon(
        LucideIcons.earth400,
        size: sizeM,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      );
    }

    // Use host-based cache key when possible to keep keys short.
    final cacheKey = Uri.tryParse(faviconUrl)?.host ?? base64Encode(utf8.encode(faviconUrl));

    return CachedNetworkImage(
      imageUrl: faviconUrl,
      cacheKey: cacheKey,
      width: sizeM,
      height: sizeM,
      fit: BoxFit.contain,
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        width: sizeM,
        height: sizeM,
        fit: BoxFit.contain,
      ),
      errorWidget: (context, url, error) => Icon(
        LucideIcons.earth400,
        size: sizeM,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      ),
      placeholder: (context, url) => Icon(
        LucideIcons.earth400,
        size: sizeM,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      ),
    );
  }

  String _getFaviconUrl() {
    final uri = Uri.tryParse(widget.url);

    if (uri != null && uri.hasScheme) {
      return 'https://icons.duckduckgo.com/ip3/${uri.host}.ico';
    } else {
      return "";
    }
  }
}
