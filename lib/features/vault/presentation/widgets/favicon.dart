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
    return Image.network(
      _getFaviconUrl(widget.url),
      width: sizeM,
      height: sizeM,
      errorBuilder: (context, error, stackTrace) => Icon(
        LucideIcons.earth400,
        size: sizeM,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      ),
    );
  }

  String _getFaviconUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return 'https://icons.duckduckgo.com/ip3/${uri.host}.ico';
    } catch (_) {
      return '';
    }
  }
}
