import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultListActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final bool enabled;

  const VaultListActions({
    super.key,
    required this.onAdd,
    required this.enabled,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: sizeXS,
      children: [
        SecondaryButton(
          caption: "Add new entry",
          icon: LucideIcons.plus,
          onPressed: onAdd,
          enabled: enabled,
          tooltip: "Add a new password to your vault",
        ),
        Spacer(),
        GlyphButton(
          icon: LucideIcons.share,
          onTap: onExport,
          enabled: enabled,
          tooltip: "Export your vault",
        ),
      ],
    );
  }
}
