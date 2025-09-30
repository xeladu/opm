import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/add_entry.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/delete_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/separator.dart';
import 'package:open_password_manager/shared/presentation/sheets/vault_entry_type_selection_sheet.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class VaultListDesktop extends ConsumerStatefulWidget {
  final List<VaultEntry> entries;
  final bool vaultEmpty;

  const VaultListDesktop({super.key, required this.entries, required this.vaultEmpty});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<VaultListDesktop> {
  VaultEntryType _selectedVaultEntryType = VaultEntryType.credential;

  @override
  Widget build(BuildContext context) {
    final selectedVaultEntry = ref.watch(selectedEntryProvider);
    final addEditModeActive = ref.watch(addEditModeActiveProvider);

    final leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${widget.entries.length} entries found"),
        SizedBox(height: sizeXS),
        VaultSearchField(),
        SizedBox(height: sizeS),
        Expanded(
          child: widget.vaultEmpty
              ? Center(
                  child: EmptyList(
                    message: "Your vault is empty!\r\nStart by adding your first entry",
                  ),
                )
              : ListView.builder(
                  itemCount: widget.entries.length,
                  itemBuilder: (context, index) {
                    final entry = widget.entries[index];
                    return VaultListEntry(
                      entry: entry,
                      selected: selectedVaultEntry?.id == entry.id,
                      isMobile: false,
                    );
                  },
                ),
        ),
        Separator.horizontal(),
        VaultListActions(
          enabled: selectedVaultEntry == null && !addEditModeActive,
          onAdd: () => _addNewEntry(),
        ),
      ],
    );

    final rightPanelContent = selectedVaultEntry == null && !addEditModeActive
        ? SizedBox()
        : Column(
            children: [
              Expanded(
                child: addEditModeActive
                    ? AddEditForm(
                        entry: selectedVaultEntry,
                        template: selectedVaultEntry == null
                            ? _selectedVaultEntryType
                            : VaultEntryType.values.firstWhere(
                                (t) => t.name.toLowerCase().contains(
                                  selectedVaultEntry.type.toLowerCase(),
                                ),
                              ),
                        onCancel: () => _cancel(),
                        onSave: () => _save(),
                      )
                    : VaultEntryDetails(
                        key: ValueKey(selectedVaultEntry!.id),
                        entry: selectedVaultEntry,
                      ),
              ),
              Separator.horizontal(),
              VaultEntryActions(
                enabled: !addEditModeActive,
                onDuplicate: () async => await _duplicate(),
                onDelete: () async => await _delete(),
                onEdit: () async => await _edit(),
              ),
            ],
          );

    return ShadResizablePanelGroup(
      children: [
        ShadResizablePanel(
          id: 1,
          defaultSize: .5,
          minSize: .33,
          child: Padding(padding: const EdgeInsets.all(sizeS), child: leftPanelContent),
        ),
        ShadResizablePanel(
          id: 2,
          defaultSize: .5,
          minSize: .33,
          child: Padding(padding: const EdgeInsets.all(sizeS), child: rightPanelContent),
        ),
      ],
    );
  }

  Future<void> _addNewEntry() async {
    if (ref.read(noConnectionProvider)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

    if (ref.read(addEditModeActiveProvider)) return;

    final result = await showShadSheet(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => VaultEntryTypeSelectionSheet(
        onSelected: (t) async {
          _selectedVaultEntryType = t;
        },
      ),
    );

    if (result != true) {
      return;
    }

    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(true);
  }

  void _save() {
    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.invalidate(allEntriesProvider);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  void _cancel() {
    ref.read(selectedEntryProvider.notifier).setEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  Future<void> _edit() async {
    if (ref.read(noConnectionProvider)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

    ref.read(addEditModeActiveProvider.notifier).setMode(!ref.read(addEditModeActiveProvider));
  }

  Future<void> _duplicate() async {
    if (ref.read(noConnectionProvider)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

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

    // update cache
    final storageService = ref.read(storageServiceProvider);
    final cryptoRepo = ref.read(cryptographyRepositoryProvider);
    final allEntries = await ref.read(allEntriesProvider.future);
    await CacheVault(storageService, cryptoRepo).call(allEntries);
  }

  Future<void> _delete() async {
    if (ref.read(noConnectionProvider)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

    final confirm = await DialogService.showDeleteDialog(context);

    if (confirm == true) {
      final repo = ref.read(vaultRepositoryProvider);
      final useCase = DeleteEntry(repo);
      final selectedPasswordEntry = ref.read(selectedEntryProvider);

      await useCase.call(selectedPasswordEntry!.id);
      ref.read(selectedEntryProvider.notifier).setEntry(null);
      ref.invalidate(allEntriesProvider);

      // update cache
      final storageService = ref.read(storageServiceProvider);
      final cryptoRepo = ref.read(cryptographyRepositoryProvider);
      final allEntries = await ref.read(allEntriesProvider.future);
      await CacheVault(storageService, cryptoRepo).call(allEntries);
    }
  }
}
