import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/active_filter_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/entry_filter_sheet.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultListActions extends ConsumerWidget {
  final VoidCallback onAdd;
  final bool enabled;

  const VaultListActions({super.key, required this.onAdd, required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      spacing: sizeXS,
      children: [
        SecondaryButton(
          caption: "Add new entry",
          icon: LucideIcons.plus,
          onPressed: onAdd,
          enabled: enabled,
          tooltip: "Add a new entry to your vault",
        ),
        Spacer(),
        ref.read(activeFilterProvider) == null
            ? GlyphButton(
                tooltip: "Show folder selection",
                onTap: () {
                  showShadSheet(
                    context: context,
                    side: ShadSheetSide.right,
                    builder: (context) => EntryFilterSheet(),
                  );
                },
                icon: LucideIcons.settings2,
              )
            : GlyphButton.important(
                tooltip: "Show folder selection",
                onTap: () {
                  showShadSheet(
                    context: context,
                    side: ShadSheetSide.right,
                    builder: (context) => EntryFilterSheet(),
                  );
                },
                icon: LucideIcons.settings2,
              ),
      ],
    );
  }
}
