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
    try {
      final uri = Uri.parse(widget.url);

      if (uri.hasScheme) {
        return Image.network(
          _getFaviconUrl(uri.host),
          width: sizeM,
          height: sizeM,
          errorBuilder: (context, error, stackTrace) => Icon(
            LucideIcons.earth400,
            size: sizeM,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        );
      } else {
        return Icon(
          LucideIcons.earth400,
          size: sizeM,
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        );
      }
    } catch (_) {
      return Icon(
        LucideIcons.earth400,
        size: sizeM,
        color: ShadTheme.of(context).colorScheme.mutedForeground,
      );
    }
  }

  String _getFaviconUrl(String host) {
    return 'https://icons.duckduckgo.com/ip3/$host.ico';
  }
}
