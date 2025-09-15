import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/presentation/sheets/vault_entry_type_selection_sheet.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddEntryButton extends ConsumerWidget {
  const AddEntryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadTooltip(
      builder: (context) => Text("Add new entry"),
      child: FloatingActionButton(
        onPressed: () async {
          if (ref.read(noConnectionProvider)) {
            await DialogService.showNoConnectionDialog(context);
            return;
          }

          VaultEntryType type = VaultEntryType.note;

          final result = await showShadSheet(
            context: context,
            side: ShadSheetSide.bottom,
            builder: (context) => VaultEntryTypeSelectionSheet(
              onSelected: (t) async {
                type = t;
              },
            ),
          );

          if (result != true) {
            return;
          }

          if (context.mounted) {
            await NavigationService.goTo(
              context,
              AddEditVaultEntryPage(
                template: type,
                onSave: () => ref.invalidate(allEntriesProvider),
              ),
            );
          }
        },
        child: Icon(LucideIcons.plus),
      ),
    );
  }
}
