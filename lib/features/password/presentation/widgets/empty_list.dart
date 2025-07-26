import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmptyList extends StatelessWidget {
  final String message;

  const EmptyList({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: sizeS,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: ShadTheme.of(context).textTheme.large,
          textAlign: TextAlign.center,
        ),
        Icon(LucideIcons.vault200, size: sizeXXL),
      ],
    );
  }
}
