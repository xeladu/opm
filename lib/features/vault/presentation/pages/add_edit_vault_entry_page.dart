import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/style/ui.dart';

class AddEditVaultEntryPage extends ConsumerWidget {
  final VaultEntry? entry;
  final VoidCallback onSave;

  const AddEditVaultEntryPage({required this.onSave, this.entry, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _cancel(context, ref);
      },
      child: ResponsiveAppFrame(
        title: entry == null ? 'Add Vault Entry' : 'Edit Vault Entry',
        content: Padding(
          padding: const EdgeInsets.all(sizeS),
          child: AddEditForm(
            entry: entry,
            onSave: () => _save(context),
            onCancel: () async => await _cancel(context, ref),
          ),
        ),
        hideSearchButton: true,
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final editModeActive = ref.read(addEditModeActiveProvider);
    final hasChanges = ref.read(hasChangesProvider);

    if (editModeActive || hasChanges) {
      // ask for confirmation before leaving the edit mode
      final confirm = await DialogService.showCancelDialog(context);

      if (confirm == true && context.mounted) {
        ref.read(addEditModeActiveProvider.notifier).setMode(false);
        ref.read(hasChangesProvider.notifier).setHasChanges(false);
        Navigator.of(context).pop();
        return;
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    Navigator.of(context).pop();
    onSave();
  }
}
