import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrimaryButton extends StatelessWidget {
  final String caption;
  final IconData? icon;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.caption,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: onPressed,
      leading: icon != null ? Icon(icon) : null,
      child: Text(caption),
    );
  }
}
