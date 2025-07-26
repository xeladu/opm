import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
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
        GlyphButton(
          enabled: enabled,
          icon: LucideIcons.pen,
          onTap: onEdit,
          tooltip: "Edit this entry",
        ),
        GlyphButton(
          enabled: enabled,
          icon: LucideIcons.copy,
          onTap: onDuplicate,
          tooltip: "Duplicate this entry",
        ),
        Spacer(),
        GlyphButton.important(
          enabled: enabled,
          icon: LucideIcons.trash,
          onTap: onDelete,
          tooltip: "Delete this entry",
        ),
      ],
    );
  }
}
