import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrimaryButton extends StatelessWidget {
  final String caption;
  final IconData? icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const PrimaryButton({
    super.key,
    required this.caption,
    required this.onPressed,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ShadButton(
      onPressed: onPressed,
      leading: icon != null ? Icon(icon) : null,
      child: Text(caption),
    );

    return tooltip != null
        ? ShadTooltip(builder: (context) => Text(tooltip!), child: button)
        : button;
  }
}
