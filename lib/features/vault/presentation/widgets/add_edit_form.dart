import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/add_entry.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/edit_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/folder.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/password_generator_sheet.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class AddEditForm extends ConsumerStatefulWidget {
  final VaultEntry? entry;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AddEditForm({super.key, this.entry, required this.onCancel, required this.onSave});

  @override
  ConsumerState<AddEditForm> createState() => _AddEditFormState();
}

class _AddEditFormState extends ConsumerState<AddEditForm> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<ShadFormState>();
  late TextEditingController _nameController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _urlsController;
  late TextEditingController _commentsController;
  late ShadSelectController<String> _folderController;
  bool _hasEntries = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry?.name ?? "");
    _userController = TextEditingController(text: widget.entry?.username ?? "");
    _passwordController = TextEditingController(text: widget.entry?.password ?? "");
    _urlsController = TextEditingController(text: widget.entry?.urls.join('\n') ?? "");
    _commentsController = TextEditingController(text: widget.entry?.comments ?? "");
    _folderController = ShadSelectController(
      initialValue: {
        widget.entry == null || widget.entry!.folder.isEmpty ? "" : widget.entry!.folder,
      },
    );

    _addListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hasChangesProvider.notifier).setHasChanges(false);
      ref.read(allEntryFoldersProvider).whenData((folders) {
        setState(() {
          _hasEntries = folders.isNotEmpty;
        });
      });
    });
  }

  @override
  void didUpdateWidget(covariant AddEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry != oldWidget.entry) {
      _removeListeners();

      _nameController.text = widget.entry?.name ?? "";
      _userController.text = widget.entry?.username ?? "";
      _passwordController.text = widget.entry?.password ?? "";
      _urlsController.text = widget.entry?.urls.join('\n') ?? "";
      _commentsController.text = widget.entry?.comments ?? "";
      _folderController.value = {
        widget.entry == null || widget.entry!.folder.isEmpty ? "" : widget.entry!.folder,
      };

      _addListeners();
    }
  }

  @override
  void dispose() {
    _removeListeners();

    _nameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _urlsController.dispose();
    _commentsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadForm(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: sizeXS,
          children: [
            ShadInputFormField(
              controller: _nameController,
              leading: Icon(LucideIcons.idCard),
              label: const Text('Name'),
              placeholder: const Text("The identifier for your password entry"),
              validator: (v) => v.isEmpty ? 'Required' : null,
            ),
            ShadInputFormField(
              controller: _userController,
              leading: Icon(LucideIcons.user),
              label: const Text('Username'),
              placeholder: const Text("Your sign in name (will be autofilled on websites)"),
            ),
            ShadInputFormField(
              controller: _passwordController,
              leading: Icon(LucideIcons.lock),
              label: const Text('Password'),
              placeholder: const Text("Your sign in password (will be autofilled on websites)"),
              obscureText: _obscurePassword,
              trailing: Row(
                spacing: sizeXS,
                children: [
                  SizedBox(
                    width: sizeS,
                    height: sizeS,
                    child: GlyphButton.ghost(
                      tooltip: "Generate password",
                      icon: LucideIcons.packagePlus,
                      onTap: () async {
                        await showShadSheet(
                          side: ShadSheetSide.right,
                          context: context,
                          builder: (context) => PasswordGeneratorSheet(
                            onGeneratePassword: (newPassword) {
                              setState(() {
                                _passwordController.text = newPassword;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: sizeS,
                    height: sizeS,
                    child: GlyphButton.ghost(
                      tooltip: "Show/hide value",
                      icon: _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      onTap: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ],
              ),
            ),
            ShadInputFormField(
              controller: _urlsController,
              label: const Text('URLs'),
              placeholder: const Text(
                "List of URLs to offer autofill with these credentials. One per line.",
              ),
              maxLines: 3,
            ),
            ShadInputFormField(
              controller: _commentsController,
              label: const Text('Comments'),
              placeholder: const Text("Password hints, 2FA reset codes, secondary tokens, ..."),
              maxLines: 2,
            ),
            Row(
              spacing: sizeS,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ShadSelectFormField<String>(
                        controller: _folderController,
                        label: const Text("Folder"),
                        placeholder: const Text(" - no folder assigned - "),
                        enabled: _hasEntries,
                        minWidth: constraints.maxWidth,
                        selectedOptionBuilder: (context, value) =>
                            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
                        options: ref
                            .watch(allEntryFoldersProvider)
                            .when(
                              data: (folders) {
                                _addDefaultFolder(folders);
                                return folders.map(
                                  (folder) => ShadOption<String>(
                                    key: Key('folder-${folder.name}'),
                                    value: folder.name,
                                    child: Text(folder.name),
                                  ),
                                );
                              },
                              loading: () => [
                                ShadOption<String>(value: "", child: Text("Loading")),
                              ],
                              error: (_, _) => [
                                ShadOption<String>(
                                  value: "",
                                  child: Text(" - no folder assigned - "),
                                ),
                              ],
                            ),
                        onChanged: (_) async {
                          // listener for controller doesn't work, so we trigger the check manually
                          await Future.delayed(Duration.zero);
                          ref.read(hasChangesProvider.notifier).setHasChanges(_anyChangesMade);
                        },
                      );
                    },
                  ),
                ),
                GlyphButton(
                  tooltip: "Create a new folder",
                  onTap: _handleCreateFolder,
                  icon: LucideIcons.folderPlus,
                ),
              ],
            ),
            const SizedBox(height: sizeXS),
            Row(
              spacing: sizeS,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ref.watch(hasChangesProvider))
                  Flexible(
                    fit: FlexFit.loose,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ShadBadge.destructive(
                        child: Text("Unsaved Changes", overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                SecondaryButton(onPressed: _cancel, caption: 'Cancel'),
                PrimaryButton(onPressed: _save, caption: 'Save'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _anyChangesMade {
    bool changesMade = false;
    final isEdit = widget.entry != null;

    if (isEdit) {
      final entry = widget.entry!;
      final urlsText = entry.urls.join('\n');

      changesMade =
          _nameController.text != entry.name ||
          _userController.text != entry.username ||
          _passwordController.text != entry.password ||
          _urlsController.text != urlsText ||
          _commentsController.text != entry.comments ||
          _folderController.value.first != entry.folder;
    } else {
      changesMade =
          _nameController.text.isNotEmpty ||
          _userController.text.isNotEmpty ||
          _passwordController.text.isNotEmpty ||
          _urlsController.text.isNotEmpty ||
          _commentsController.text.isNotEmpty ||
          _folderController.value.first != "";
    }

    return changesMade;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final entry = VaultEntry(
        id: widget.entry == null || widget.entry!.id.isEmpty ? const Uuid().v4() : widget.entry!.id,
        name: _nameController.text,
        createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
        updatedAt: now.toIso8601String(),
        username: _userController.text,
        password: _passwordController.text,
        urls: _urlsController.text
            .split(';')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        comments: _commentsController.text,
        folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
      );

      final repo = ref.read(vaultRepositoryProvider);
      // entry == null => add new
      // entry.id empty => duplicate
      widget.entry == null || widget.entry!.id.isEmpty
          ? await AddEntry(repo).call(entry)
          : await EditEntry(repo).call(entry);

      // update cache
      final storageService = ref.read(storageServiceProvider);
      final cryptoRepo = ref.read(cryptographyRepositoryProvider);
      final allEntries = await ref.read(allEntriesProvider.future);
      await CacheVault(storageService, cryptoRepo).call(allEntries);

      ref.read(hasChangesProvider.notifier).setHasChanges(false);
      widget.onSave();
    }
  }

  Future<void> _cancel() async {
    if (!ref.read(hasChangesProvider)) {
      widget.onCancel();
    } else {
      final confirm = await DialogService.showCancelDialog(context);

      if (confirm == true) {
        ref.read(selectedEntryProvider.notifier).setEntry(null);
        ref.read(hasChangesProvider.notifier).setHasChanges(false);
        widget.onCancel();
      }
    }
  }

  void _listenForChanges() {
    ref.read(hasChangesProvider.notifier).setHasChanges(_anyChangesMade);
  }

  void _addListeners() {
    _nameController.addListener(_listenForChanges);
    _userController.addListener(_listenForChanges);
    _passwordController.addListener(_listenForChanges);
    _urlsController.addListener(_listenForChanges);
    _commentsController.addListener(_listenForChanges);

    // ShadSelectController is not firing when a value changes so we cannot use a listener
  }

  void _removeListeners() {
    _nameController.removeListener(_listenForChanges);
    _userController.removeListener(_listenForChanges);
    _passwordController.removeListener(_listenForChanges);
    _urlsController.removeListener(_listenForChanges);
    _commentsController.removeListener(_listenForChanges);
  }

  Future<void> _handleCreateFolder() async {
    final newFolderName = await DialogService.showFolderCreationDialog(context, ref);

    // Delay required for the animated dialog to close. Otherwise, an error message is shown.
    await Future.delayed(Duration(milliseconds: 250));

    if (newFolderName != null) {
      ref.read(allEntryFoldersProvider.notifier).addFolder(newFolderName);
    }
  }

  void _addDefaultFolder(List<Folder> folders) {
    if (folders.any((folder) => folder.isDefaultFolder)) return;

    folders.insert(
      0,
      Folder(
        name: "No folder",
        isDefaultFolder: true,
        entryCount: ref
            .read(allEntriesProvider)
            .maybeWhen(data: (list) => list.length, orElse: () => 0),
      ),
    );
  }
}
