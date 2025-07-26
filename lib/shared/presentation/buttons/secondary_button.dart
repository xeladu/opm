import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SecondaryButton extends StatelessWidget {
  final String caption;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;

  const SecondaryButton({
    super.key,
    required this.caption,
    required this.onPressed,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton.secondary(
      onPressed: onPressed,
      leading: icon != null ? Icon(icon) : null,
      enabled: enabled,
      child: Text(caption),
    );
  }
}
