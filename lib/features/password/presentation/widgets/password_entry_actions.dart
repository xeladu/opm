import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordEntryActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool enabled;

  const PasswordEntryActions({
    super.key,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: sizeXS,
      children: [
        ShadIconButton.secondary(
          enabled: enabled,
          icon: const Icon(LucideIcons.pen),
          onPressed: onEdit,
        ),
        ShadIconButton.secondary(
          enabled: enabled,
          icon: const Icon(LucideIcons.copy),
          onPressed: onDuplicate,
        ),
        Spacer(),
        ShadIconButton.destructive(
          enabled: enabled,
          icon: const Icon(LucideIcons.trash),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
