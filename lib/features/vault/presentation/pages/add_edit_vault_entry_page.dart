import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/style/ui.dart';

class AddEditVaultEntryPage extends StatelessWidget {
  final VaultEntry? entry;
  final Future<void> Function(VaultEntry) onSave;

  const AddEditVaultEntryPage({required this.onSave, this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _cancel(context);
      },
      child: ResponsiveAppFrame(
        title: entry == null ? 'Add Password Entry' : 'Edit Password Entry',
        content: Padding(
          padding: const EdgeInsets.all(sizeS),
          child: AddEditForm(
            onSave: () => _save(context),
            onCancel: () async => await _cancel(context),
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final confirm = await DialogService.showCancelDialog(context);

    if (confirm == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save(BuildContext context) async {
    Navigator.of(context).pop();
  }
}
