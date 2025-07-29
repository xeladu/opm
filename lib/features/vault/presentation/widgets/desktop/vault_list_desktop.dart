import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/add_entry.dart';
import 'package:open_password_manager/features/vault/application/use_cases/delete_entry.dart';
import 'package:open_password_manager/features/vault/application/use_cases/export_vault.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class VaultListDesktop extends ConsumerWidget {
  final List<VaultEntry> passwords;
  final bool vaultEmpty;

  const VaultListDesktop({
    super.key,
    required this.passwords,
    required this.vaultEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPasswordEntry = ref.watch(selectedEntryProvider);
    final addEditModeActive = ref.watch(addEditModeActiveProvider);

    final leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${passwords.length} entries found"),
        SizedBox(height: sizeXS),
        VaultSearchField(),
        SizedBox(height: sizeS),
        Expanded(
          child: vaultEmpty
              ? Center(
                  child: EmptyList(
                    message:
                        "Your vault is empty!\r\nStart by adding your first entry",
                  ),
                )
              : ListView.builder(
                  itemCount: passwords.length,
                  itemBuilder: (context, index) {
                    final entry = passwords[index];
                    return VaultListEntry(
                      entry: entry,
                      selected: selectedPasswordEntry?.id == entry.id,
                      isMobile: false,
                    );
                  },
                ),
        ),
        Divider(),
        VaultListActions(
          enabled: ref.watch(selectedEntryProvider) == null,
          onAdd: () => _addNewEntry(ref),
          onExport: () => _exportVault(context, ref),
        ),
      ],
    );

    final rightPanelContent =
        selectedPasswordEntry == null && !addEditModeActive
        ? SizedBox()
        : Column(
            children: [
              Expanded(
                child: addEditModeActive
                    ? AddEditForm(
                        entry: selectedPasswordEntry,
                        onCancel: () => _cancel(ref),
                        onSave: () => _save(ref),
                      )
                    : VaultEntryDetails(
                        key: ValueKey(selectedPasswordEntry!.id),
                        entry: selectedPasswordEntry,
                      ),
              ),
              Divider(),
              VaultEntryActions(
                enabled: !addEditModeActive,
                onDuplicate: () async => await _duplicate(ref),
                onDelete: () async => await _delete(ref, context),
                onEdit: () => _edit(ref),
              ),
            ],
          );

    return ShadResizablePanelGroup(
      children: [
        ShadResizablePanel(
          id: 1,
          defaultSize: .5,
          minSize: .33,
          child: Padding(
            padding: const EdgeInsets.all(sizeS),
            child: leftPanelContent,
          ),
        ),
        ShadResizablePanel(
          id: 2,
          defaultSize: .5,
          minSize: .33,
          child: Padding(
            padding: const EdgeInsets.all(sizeS),
            child: rightPanelContent,
          ),
        ),
      ],
    );
  }

  void _addNewEntry(WidgetRef ref) {
    if (ref.read(addEditModeActiveProvider)) return;

    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(true);
  }

  Future<void> _exportVault(BuildContext context, WidgetRef ref) async {
    final pwRepo = ref.read(vaultRepositoryProvider);
    final exportRepo = ref.read(exportRepositoryProvider);
    final useCase = ExportVault(pwRepo, exportRepo);
    await useCase();

    if (context.mounted) {
      ToastService.show(context, "Vault exported");
    }
  }

  void _save(WidgetRef ref) {
    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.invalidate(allEntriesProvider);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  void _cancel(WidgetRef ref) {
    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  void _edit(WidgetRef ref) {
    ref
        .read(addEditModeActiveProvider.notifier)
        .setMode(!ref.read(addEditModeActiveProvider));
  }

  Future<void> _duplicate(WidgetRef ref) async {
    final original = ref.read(selectedEntryProvider)!;
    final selectedEntryCopy = original.copyWith(
      id: Uuid().v4(),
      createdAt: DateTime.now().toIso8601String(),
      name: "${original.name} copy",
    );

    final repo = ref.read(vaultRepositoryProvider);
    final useCase = AddEntry(repo);
    await useCase(selectedEntryCopy);

    ref.read(selectedEntryProvider.notifier).setEntry(null);
    ref.invalidate(allEntriesProvider);
  }

  Future<void> _delete(WidgetRef ref, BuildContext context) async {
    final confirm = await DialogService.showDeleteDialog(context);

    if (confirm == true) {
      final repo = ref.read(vaultRepositoryProvider);
      final useCase = DeleteEntry(repo);
      final selectedPasswordEntry = ref.read(selectedEntryProvider);

      await useCase.call(selectedPasswordEntry!.id);
      ref.read(selectedEntryProvider.notifier).setEntry(null);
      ref.invalidate(allEntriesProvider);
    }
  }
}
