import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/application/providers/all_password_entries_provider.dart';
import 'package:open_password_manager/features/password/application/providers/password_entry_edit_mode_provider.dart';
import 'package:open_password_manager/features/password/application/providers/selected_password_entry_provider.dart';
import 'package:open_password_manager/features/password/application/use_cases/add_password_entry.dart';
import 'package:open_password_manager/features/password/application/use_cases/delete_password_entry.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/features/password/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_entry_actions.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_entry_details.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_list_actions.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_list_entry.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_search_field.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class PasswordListDesktop extends ConsumerWidget {
  final List<PasswordEntry> passwords;

  const PasswordListDesktop({super.key, required this.passwords});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPasswordEntry = ref.watch(selectedPasswordEntryProvider);
    final addEditModeActive = ref.watch(addEditModeActiveProvider);

    final leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${passwords.length} entries found"),
        SizedBox(height: sizeXS),
        PasswordSearchField(),
        SizedBox(height: sizeS),
        Expanded(
          child: ListView.builder(
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final entry = passwords[index];
              return PasswordListEntry(
                entry: entry,
                selected: selectedPasswordEntry?.id == entry.id,
                isMobile: false,
              );
            },
          ),
        ),
        Divider(),
        PasswordListActions(
          enabled: ref.watch(selectedPasswordEntryProvider) == null,
          onAdd: () => _addNewEntry(ref),
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
                    : PasswordEntryDetails(
                        key: ValueKey(selectedPasswordEntry!.id),
                        entry: selectedPasswordEntry,
                      ),
              ),
              Divider(),
              PasswordEntryActions(
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

    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(true);
  }

  void _save(WidgetRef ref) {
    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);

    ref.invalidate(allPasswordEntriesProvider);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  void _cancel(WidgetRef ref) {
    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
  }

  void _edit(WidgetRef ref) {
    ref
        .read(addEditModeActiveProvider.notifier)
        .setMode(!ref.read(addEditModeActiveProvider));
  }

  Future<void> _duplicate(WidgetRef ref) async {
    final original = ref.read(selectedPasswordEntryProvider)!;
    final selectedEntryCopy = original.copyWith(
      id: Uuid().v4(),
      createdAt: DateTime.now().toIso8601String(),
      name: "${original.name} copy",
    );

    final repo = ref.read(passwordRepositoryProvider);
    final useCase = AddPasswordEntry(repo);
    await useCase(selectedEntryCopy);

    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);
    ref.invalidate(allPasswordEntriesProvider);
  }

  Future<void> _delete(WidgetRef ref, BuildContext context) async {
    final confirm = await DialogService.showDeleteDialog(context);

    if (confirm == true) {
      final repo = ref.read(passwordRepositoryProvider);
      final useCase = DeletePasswordEntry(repo);
      final selectedPasswordEntry = ref.read(selectedPasswordEntryProvider);

      await useCase.call(selectedPasswordEntry!.id);
      ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);
      ref.invalidate(allPasswordEntriesProvider);
    }
  }
}
