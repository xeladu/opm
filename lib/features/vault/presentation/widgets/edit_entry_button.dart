import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditEntryButton extends ConsumerWidget {
  final VaultEntry entry;
  
  const EditEntryButton({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadTooltip(
      builder: (context) => Text("Edit this entry"),
      child: FloatingActionButton(
        onPressed: () async {
          await NavigationService.goTo(
            context,
            AddEditVaultEntryPage(
              entry: entry,
              onSave: () => ref.invalidate(allEntriesProvider),
            ),
          );
        },
        child: Icon(LucideIcons.pen),
      ),
    );
  }
}
