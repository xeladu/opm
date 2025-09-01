import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TransparentButton extends StatelessWidget {
  final String caption;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;
  final String? tooltip;

  const TransparentButton({
    super.key,
    required this.caption,
    required this.onPressed,
    this.enabled = true,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ShadButton.ghost(
      onPressed: onPressed,
      leading: icon != null ? Icon(icon) : null,
      enabled: enabled,
      child: Text(caption, style: ShadTheme.of(context).textTheme.muted),
    );

    return tooltip != null
        ? ShadTooltip(builder: (context) => Text(tooltip!), child: button)
        : button;
  }
}
