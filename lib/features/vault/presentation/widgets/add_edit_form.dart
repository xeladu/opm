import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/add_entry.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/edit_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/card_issuer.dart';
import 'package:open_password_manager/features/vault/domain/entities/custom_folder.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
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
  final VaultEntryType template;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AddEditForm({
    super.key,
    this.entry,
    required this.template,
    required this.onCancel,
    required this.onSave,
  });

  @override
  ConsumerState<AddEditForm> createState() => _AddEditFormState();
}

class _AddEditFormState extends ConsumerState<AddEditForm> {
  bool _obscureSecrets = true;
  final _formKey = GlobalKey<ShadFormState>();
  late TextEditingController _nameController;
  late TextEditingController _commentsController;
  late ShadSelectController<String> _folderController;

  // credentials
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _urlsController;

  // ssh
  late TextEditingController _sshPrivateKeyController;
  late TextEditingController _sshPublicKeyController;
  late TextEditingController _sshFingerprintController;

  // bank/credit card
  late TextEditingController _cardHolderNameController;
  late TextEditingController _cardNumberController;
  late ShadSelectController<CardIssuer> _cardIssuerController;
  late TextEditingController _cardSecurityCodeController;
  late ShadSelectController<int> _cardExpirationMonthController;
  late ShadSelectController<int> _cardExpirationYearController;
  late TextEditingController _cardPinController;

  // api
  late TextEditingController _apiKeyController;

  // oauth
  late TextEditingController _oauthProviderController;
  late TextEditingController _oauthClientIdController;
  late TextEditingController _oauthAccessTokenController;
  late TextEditingController _oauthRefreshTokenController;

  // wifi
  late TextEditingController _wifiSsidController;
  late TextEditingController _wifiPasswordController;

  // pgp
  late TextEditingController _pgpPrivateKeyController;
  late TextEditingController _pgpPublicKeyController;
  late TextEditingController _pgpFingerprintController;

  // s-mime
  late TextEditingController _smimeCertificateController;
  late TextEditingController _smimePrivateKeyController;

  bool _hasEntries = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry?.name ?? "");
    _commentsController = TextEditingController(text: widget.entry?.comments ?? "");
    _folderController = ShadSelectController(
      initialValue: {
        widget.entry == null || widget.entry!.folder.isEmpty ? "" : widget.entry!.folder,
      },
    );

    _userController = TextEditingController(text: widget.entry?.username ?? "");
    _passwordController = TextEditingController(text: widget.entry?.password ?? "");
    _urlsController = TextEditingController(text: widget.entry?.urls.join('\n') ?? "");

    _sshPrivateKeyController = TextEditingController(text: widget.entry?.sshPrivateKey ?? "");
    _sshPublicKeyController = TextEditingController(text: widget.entry?.sshPublicKey ?? "");
    _sshFingerprintController = TextEditingController(text: widget.entry?.sshFingerprint ?? "");

    _cardExpirationMonthController = ShadSelectController(
      initialValue: {
        widget.entry == null || int.tryParse(widget.entry!.cardExpirationMonth) == null
            ? 0
            : int.parse(widget.entry!.cardExpirationMonth),
      },
    );
    _cardExpirationYearController = ShadSelectController(
      initialValue: {
        widget.entry == null || int.tryParse(widget.entry!.cardExpirationYear) == null
            ? 0
            : int.parse(widget.entry!.cardExpirationYear),
      },
    );
    _cardHolderNameController = TextEditingController(text: widget.entry?.cardHolderName ?? "");
    _cardIssuerController = ShadSelectController(
      initialValue: {
        widget.entry == null
            ? CardIssuer.visa
            : CardIssuer.values.firstWhere(
                (c) => c.name == widget.entry!.cardIssuer,
                orElse: () => CardIssuer.visa,
              ),
      },
    );
    _cardNumberController = TextEditingController(text: widget.entry?.cardNumber ?? "");
    _cardPinController = TextEditingController(text: widget.entry?.cardPin ?? "");
    _cardSecurityCodeController = TextEditingController(text: widget.entry?.cardSecurityCode ?? "");

    _apiKeyController = TextEditingController(text: widget.entry?.apiKey ?? "");

    _oauthAccessTokenController = TextEditingController(text: widget.entry?.oauthAccessToken ?? "");
    _oauthClientIdController = TextEditingController(text: widget.entry?.oauthClientId ?? "");
    _oauthProviderController = TextEditingController(text: widget.entry?.oauthProvider ?? "");
    _oauthRefreshTokenController = TextEditingController(
      text: widget.entry?.oauthRefreshToken ?? "",
    );

    _wifiPasswordController = TextEditingController(text: widget.entry?.wifiPassword ?? "");
    _wifiSsidController = TextEditingController(text: widget.entry?.wifiSsid ?? "");

    _pgpPrivateKeyController = TextEditingController(text: widget.entry?.pgpPrivateKey ?? "");
    _pgpPublicKeyController = TextEditingController(text: widget.entry?.pgpPublicKey ?? "");
    _pgpFingerprintController = TextEditingController(text: widget.entry?.pgpFingerprint ?? "");

    _smimeCertificateController = TextEditingController(text: widget.entry?.smimeCertificate ?? "");
    _smimePrivateKeyController = TextEditingController(text: widget.entry?.smimePrivateKey ?? "");

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
      _commentsController.text = widget.entry?.comments ?? "";
      _folderController.value = {
        widget.entry == null || widget.entry!.folder.isEmpty ? "" : widget.entry!.folder,
      };

      _userController.text = widget.entry?.username ?? "";
      _passwordController.text = widget.entry?.password ?? "";
      _urlsController.text = widget.entry?.urls.join('\n') ?? "";

      _sshPrivateKeyController.text = widget.entry?.sshPrivateKey ?? "";
      _sshPublicKeyController.text = widget.entry?.sshPublicKey ?? "";
      _sshFingerprintController.text = widget.entry?.sshFingerprint ?? "";

      _cardExpirationMonthController = ShadSelectController(
        initialValue: {
          widget.entry == null || int.tryParse(widget.entry!.cardExpirationMonth) == null
              ? 0
              : int.parse(widget.entry!.cardExpirationMonth),
        },
      );
      _cardExpirationYearController = ShadSelectController(
        initialValue: {
          widget.entry == null || int.tryParse(widget.entry!.cardExpirationYear) == null
              ? 0
              : int.parse(widget.entry!.cardExpirationYear),
        },
      );
      _cardHolderNameController.text = widget.entry?.cardHolderName ?? "";
      _cardIssuerController = ShadSelectController(
        initialValue: {
          widget.entry == null
              ? CardIssuer.visa
              : CardIssuer.values.firstWhere(
                  (c) => c.name == widget.entry!.cardIssuer,
                  orElse: () => CardIssuer.visa,
                ),
        },
      );
      _cardNumberController.text = widget.entry?.cardNumber ?? "";
      _cardPinController.text = widget.entry?.cardPin ?? "";
      _cardSecurityCodeController.text = widget.entry?.cardSecurityCode ?? "";

      _apiKeyController.text = widget.entry?.apiKey ?? "";

      _oauthAccessTokenController.text = widget.entry?.oauthAccessToken ?? "";
      _oauthClientIdController.text = widget.entry?.oauthClientId ?? "";
      _oauthProviderController.text = widget.entry?.oauthProvider ?? "";
      _oauthRefreshTokenController.text = widget.entry?.oauthRefreshToken ?? "";

      _wifiPasswordController.text = widget.entry?.wifiPassword ?? "";
      _wifiSsidController.text = widget.entry?.wifiSsid ?? "";

      _pgpPrivateKeyController.text = widget.entry?.pgpPrivateKey ?? "";
      _pgpPublicKeyController.text = widget.entry?.pgpPublicKey ?? "";
      _pgpFingerprintController.text = widget.entry?.pgpFingerprint ?? "";

      _smimeCertificateController.text = widget.entry?.smimeCertificate ?? "";
      _smimePrivateKeyController.text = widget.entry?.smimePrivateKey ?? "";

      _addListeners();
    }
  }

  @override
  void dispose() {
    _removeListeners();

    _nameController.dispose();
    _commentsController.dispose();
    _folderController.dispose();

    _userController.dispose();
    _passwordController.dispose();
    _urlsController.dispose();

    _sshFingerprintController.dispose();
    _sshPrivateKeyController.dispose();
    _sshPublicKeyController.dispose();

    _cardExpirationMonthController.dispose();
    _cardExpirationYearController.dispose();
    _cardHolderNameController.dispose();
    _cardIssuerController.dispose();
    _cardNumberController.dispose();
    _cardPinController.dispose();
    _cardSecurityCodeController.dispose();

    _apiKeyController.dispose();

    _oauthAccessTokenController.dispose();
    _oauthClientIdController.dispose();
    _oauthProviderController.dispose();
    _oauthRefreshTokenController.dispose();

    _wifiPasswordController.dispose();
    _wifiSsidController.dispose();

    _pgpFingerprintController.dispose();
    _pgpPrivateKeyController.dispose();
    _pgpPublicKeyController.dispose();

    _smimeCertificateController.dispose();
    _smimePrivateKeyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadForm(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: sizeXS,
          children: [
            ShadInputFormField(
              key: ValueKey("name"),
              controller: _nameController,
              leading: Icon(LucideIcons.idCard),
              label: const Text('Name'),
              placeholder: const Text("The identifier for this entry"),
              validator: (v) => v.isEmpty ? 'Required' : null,
            ),
            ..._addTypeFields(),
            ShadInputFormField(
              key: ValueKey("comments"),
              controller: _commentsController,
              label: const Text('Comments'),
              placeholder: const Text(
                "Password hints, 2FA reset codes, secondary tokens, answers to security questions...",
              ),
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
                        trailing: _folderController.value.first != ""
                            ? SizedBox(
                                width: sizeS,
                                height: sizeS,
                                child: GlyphButton.ghost(
                                  tooltip: 'Remove folder assignment',
                                  icon: LucideIcons.x,
                                  onTap: () {
                                    setState(() {
                                      _folderController.value = {""};
                                    });
                                    ref
                                        .read(hasChangesProvider.notifier)
                                        .setHasChanges(_anyChangesMade);
                                  },
                                ),
                              )
                            : const SizedBox(),
                        key: ValueKey("folder"),
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
                                    value: folder.isDefaultFolder ? "" : folder.name,
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
          _sshFingerprintController.text != entry.sshFingerprint ||
          _sshPrivateKeyController.text != entry.sshPrivateKey ||
          _sshPublicKeyController.text != entry.sshPublicKey ||
          (_cardExpirationMonthController.value.isNotEmpty
                  ? _cardExpirationMonthController.value.first
                  : '') !=
              entry.cardExpirationMonth ||
          (_cardExpirationYearController.value.isNotEmpty
                  ? _cardExpirationYearController.value.first
                  : '') !=
              entry.cardExpirationYear ||
          _cardHolderNameController.text != entry.cardHolderName ||
          _cardIssuerController.value.first.name != entry.cardIssuer ||
          _cardNumberController.text != entry.cardNumber ||
          _cardPinController.text != entry.cardPin ||
          _cardSecurityCodeController.text != entry.cardSecurityCode ||
          _apiKeyController.text != entry.apiKey ||
          _oauthAccessTokenController.text != entry.oauthAccessToken ||
          _oauthClientIdController.text != entry.oauthClientId ||
          _oauthProviderController.text != entry.oauthProvider ||
          _oauthRefreshTokenController.text != entry.oauthRefreshToken ||
          _wifiPasswordController.text != entry.wifiPassword ||
          _wifiSsidController.text != entry.wifiSsid ||
          _pgpFingerprintController.text != entry.pgpFingerprint ||
          _pgpPrivateKeyController.text != entry.pgpPrivateKey ||
          _pgpPublicKeyController.text != entry.pgpPublicKey ||
          _smimeCertificateController.text != entry.smimeCertificate ||
          _smimePrivateKeyController.text != entry.smimePrivateKey ||
          _folderController.value.first != entry.folder;
    } else {
      changesMade =
          _nameController.text.isNotEmpty ||
          _userController.text.isNotEmpty ||
          _passwordController.text.isNotEmpty ||
          _urlsController.text.isNotEmpty ||
          _commentsController.text.isNotEmpty ||
          _sshFingerprintController.text.isNotEmpty ||
          _sshPrivateKeyController.text.isNotEmpty ||
          _sshPublicKeyController.text.isNotEmpty ||
          _cardExpirationMonthController.value.isNotEmpty ||
          _cardExpirationYearController.value.isNotEmpty ||
          _cardHolderNameController.text.isNotEmpty ||
          _cardIssuerController.value.isNotEmpty ||
          _cardNumberController.text.isNotEmpty ||
          _cardPinController.text.isNotEmpty ||
          _cardSecurityCodeController.text.isNotEmpty ||
          _apiKeyController.text.isNotEmpty ||
          _oauthAccessTokenController.text.isNotEmpty ||
          _oauthClientIdController.text.isNotEmpty ||
          _oauthProviderController.text.isNotEmpty ||
          _oauthRefreshTokenController.text.isNotEmpty ||
          _wifiPasswordController.text.isNotEmpty ||
          _wifiSsidController.text.isNotEmpty ||
          _pgpFingerprintController.text.isNotEmpty ||
          _pgpPrivateKeyController.text.isNotEmpty ||
          _pgpPublicKeyController.text.isNotEmpty ||
          _smimeCertificateController.text.isNotEmpty ||
          _smimePrivateKeyController.text.isNotEmpty ||
          _folderController.value.first != "";
    }

    return changesMade;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final type = VaultEntryType.values.firstWhere(
        (t) => t.name.toLowerCase().contains(widget.template.name.toLowerCase()),
      );

      late VaultEntry entry;
      switch (type) {
        case VaultEntryType.note:
          entry = VaultEntry.note(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
          );
          break;
        case VaultEntryType.credential:
          entry = VaultEntry.credential(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            username: _userController.text,
            password: _passwordController.text,
            urls: _urlsController.text
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
          );
          break;
        case VaultEntryType.card:
          entry = VaultEntry.card(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            cardNumber: _cardNumberController.text,
            cardHolderName: _cardHolderNameController.text,
            cardIssuer: _cardIssuerController.value.first.name,
            cardExpirationMonth: _cardExpirationMonthController.value.isNotEmpty
                ? _cardExpirationMonthController.value.first.toString()
                : '',
            cardExpirationYear: _cardExpirationYearController.value.isNotEmpty
                ? _cardExpirationYearController.value.first.toString()
                : '',
            cardSecurityCode: _cardSecurityCodeController.text,
            cardPin: _cardPinController.text,
          );
          break;
        case VaultEntryType.ssh:
          entry = VaultEntry.ssh(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            sshPrivateKey: _sshPrivateKeyController.text,
            sshPublicKey: _sshPublicKeyController.text,
            sshFingerprint: _sshFingerprintController.text,
          );
          break;
        case VaultEntryType.api:
          entry = VaultEntry.api(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            apiKey: _apiKeyController.text,
          );
          break;
        case VaultEntryType.oauth:
          entry = VaultEntry.oauth(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            oauthAccessToken: _oauthAccessTokenController.text,
            oauthClientId: _oauthClientIdController.text,
            oauthProvider: _oauthProviderController.text,
            oauthRefreshToken: _oauthRefreshTokenController.text,
          );
          break;
        case VaultEntryType.wifi:
          entry = VaultEntry.wifi(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            wifiSsid: _wifiSsidController.text,
            wifiPassword: _wifiPasswordController.text,
          );
          break;
        case VaultEntryType.pgp:
          entry = VaultEntry.pgp(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            pgpPrivateKey: _pgpPrivateKeyController.text,
            pgpPublicKey: _pgpPublicKeyController.text,
            pgpFingerprint: _pgpFingerprintController.text,
          );
          break;
        case VaultEntryType.smime:
          entry = VaultEntry.smime(
            id: widget.entry == null || widget.entry!.id.isEmpty
                ? const Uuid().v4()
                : widget.entry!.id,
            name: _nameController.text,
            createdAt: widget.entry == null ? now.toIso8601String() : widget.entry!.createdAt,
            updatedAt: now.toIso8601String(),
            comments: _commentsController.text,
            folder: _folderController.value.isEmpty ? "" : _folderController.value.first,
            smimePrivateKey: _smimePrivateKeyController.text,
            smimeCertificate: _smimeCertificateController.text,
          );
          break;
      }

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
    _commentsController.addListener(_listenForChanges);

    _userController.addListener(_listenForChanges);
    _passwordController.addListener(_listenForChanges);
    _urlsController.addListener(_listenForChanges);

    _sshFingerprintController.addListener(_listenForChanges);
    _sshPrivateKeyController.addListener(_listenForChanges);
    _sshPublicKeyController.addListener(_listenForChanges);

    _cardExpirationMonthController.addListener(_listenForChanges);
    _cardExpirationYearController.addListener(_listenForChanges);
    _cardHolderNameController.addListener(_listenForChanges);
    _cardIssuerController.addListener(_listenForChanges);
    _cardNumberController.addListener(_listenForChanges);
    _cardPinController.addListener(_listenForChanges);
    _cardSecurityCodeController.addListener(_listenForChanges);

    _apiKeyController.addListener(_listenForChanges);

    _oauthAccessTokenController.addListener(_listenForChanges);
    _oauthClientIdController.addListener(_listenForChanges);
    _oauthProviderController.addListener(_listenForChanges);
    _oauthRefreshTokenController.addListener(_listenForChanges);

    _wifiPasswordController.addListener(_listenForChanges);
    _wifiSsidController.addListener(_listenForChanges);

    _pgpFingerprintController.addListener(_listenForChanges);
    _pgpPrivateKeyController.addListener(_listenForChanges);
    _pgpPublicKeyController.addListener(_listenForChanges);

    _smimeCertificateController.addListener(_listenForChanges);
    _smimePrivateKeyController.addListener(_listenForChanges);

    // ShadSelectController is not firing when a value changes so we cannot use a listener
  }

  void _removeListeners() {
    _nameController.removeListener(_listenForChanges);
    _commentsController.removeListener(_listenForChanges);

    _userController.removeListener(_listenForChanges);
    _passwordController.removeListener(_listenForChanges);
    _urlsController.removeListener(_listenForChanges);

    _sshFingerprintController.removeListener(_listenForChanges);
    _sshPrivateKeyController.removeListener(_listenForChanges);
    _sshPublicKeyController.removeListener(_listenForChanges);

    _cardExpirationMonthController.removeListener(_listenForChanges);
    _cardExpirationYearController.removeListener(_listenForChanges);
    _cardHolderNameController.removeListener(_listenForChanges);
    _cardIssuerController.removeListener(_listenForChanges);
    _cardNumberController.removeListener(_listenForChanges);
    _cardPinController.removeListener(_listenForChanges);
    _cardSecurityCodeController.removeListener(_listenForChanges);

    _apiKeyController.removeListener(_listenForChanges);

    _oauthAccessTokenController.removeListener(_listenForChanges);
    _oauthClientIdController.removeListener(_listenForChanges);
    _oauthProviderController.removeListener(_listenForChanges);
    _oauthRefreshTokenController.removeListener(_listenForChanges);

    _wifiPasswordController.removeListener(_listenForChanges);
    _wifiSsidController.removeListener(_listenForChanges);

    _pgpFingerprintController.removeListener(_listenForChanges);
    _pgpPrivateKeyController.removeListener(_listenForChanges);
    _pgpPublicKeyController.removeListener(_listenForChanges);

    _smimeCertificateController.removeListener(_listenForChanges);
    _smimePrivateKeyController.removeListener(_listenForChanges);
  }

  Future<void> _handleCreateFolder() async {
    final newFolderName = await DialogService.showFolderCreationDialog(context, ref);

    // Delay required for the animated dialog to close. Otherwise, an error message is shown.
    await Future.delayed(Duration(milliseconds: 250));

    if (newFolderName != null) {
      ref.read(allEntryFoldersProvider.notifier).addFolder(newFolderName);
      // Ensure the UI enables the folder selector and selects the newly created folder.
      setState(() {
        _hasEntries = true;
        _folderController.value = {newFolderName};
      });

      // Update the hasChanges provider since selecting a folder counts as a change.
      ref.read(hasChangesProvider.notifier).setHasChanges(_anyChangesMade);
    }
  }

  void _addDefaultFolder(List<CustomFolder> folders) {
    if (folders.any((folder) => folder.isDefaultFolder)) return;

    folders.insert(
      0,
      CustomFolder(
        name: "All entries",
        isDefaultFolder: true,
        entryCount: ref
            .read(allEntriesProvider)
            .maybeWhen(data: (list) => list.length, orElse: () => 0),
      ),
    );
  }

  List<Widget> _addTypeFields() {
    switch (widget.template) {
      case VaultEntryType.note:
        return [];
      case VaultEntryType.credential:
        return _addCredentialFields();
      case VaultEntryType.card:
        return _addCardFields();
      case VaultEntryType.ssh:
        return _addSshFields();
      case VaultEntryType.api:
        return _addApiFields();
      case VaultEntryType.oauth:
        return _addOauthFields();
      case VaultEntryType.wifi:
        return _addWifiFields();
      case VaultEntryType.pgp:
        return _addPgpFields();
      case VaultEntryType.smime:
        return _addSmimeFields();
    }
  }

  List<Widget> _addCredentialFields() {
    return [
      ShadInputFormField(
        key: ValueKey("username"),
        controller: _userController,
        leading: Icon(LucideIcons.user),
        label: const Text('Username'),
        placeholder: const Text("Your sign in name (will be autofilled on websites)"),
      ),
      ShadInputFormField(
        key: ValueKey("password"),
        controller: _passwordController,
        leading: Icon(LucideIcons.lock),
        label: const Text('Password'),
        placeholder: const Text("Your sign in password (will be autofilled on websites)"),
        obscureText: _obscureSecrets,
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
                icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
                onTap: () {
                  setState(() => _obscureSecrets = !_obscureSecrets);
                },
              ),
            ),
          ],
        ),
      ),
      ShadInputFormField(
        key: ValueKey("urls"),
        controller: _urlsController,
        label: const Text('URLs'),
        placeholder: const Text(
          "List of URLs to offer autofill with these credentials. One per line.",
        ),
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _addSshFields() {
    return [
      ShadInputFormField(
        key: ValueKey("sshPrivateKey"),
        controller: _sshPrivateKeyController,
        leading: Icon(LucideIcons.lock),
        label: const Text('SSH Private Key'),
        placeholder: const Text("Your SSH Private Key"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
      ShadInputFormField(
        key: ValueKey("sshPublicKey"),
        controller: _sshPublicKeyController,
        leading: Icon(LucideIcons.handHelping),
        label: const Text('SSH Public Key'),
        placeholder: const Text("Your SSH Public Key"),
      ),
      ShadInputFormField(
        key: ValueKey("sshFingerprint"),
        controller: _sshFingerprintController,
        leading: Icon(LucideIcons.idCard),
        label: const Text('SSH Fingerprint'),
        placeholder: const Text("Your SSH Fingerprint"),
      ),
    ];
  }

  List<Widget> _addOauthFields() {
    return [
      ShadInputFormField(
        key: ValueKey("oauthAccessToken"),
        controller: _oauthAccessTokenController,
        leading: Icon(LucideIcons.lock),
        label: const Text('OAuth Access Token'),
        placeholder: const Text("Your OAuth Access Token"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
      ShadInputFormField(
        key: ValueKey("oauthRefreshToken"),
        controller: _oauthRefreshTokenController,
        leading: Icon(LucideIcons.lock),
        label: const Text('OAuth Refresh Token'),
        placeholder: const Text("Your OAuth Refresh Token"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
      ShadInputFormField(
        key: ValueKey("oauthClientId"),
        controller: _oauthClientIdController,
        leading: Icon(LucideIcons.handHelping),
        label: const Text('OAuth Client ID'),
        placeholder: const Text("Your OAuth Client ID"),
      ),
      ShadInputFormField(
        key: ValueKey("oauthProvider"),
        controller: _oauthProviderController,
        leading: Icon(LucideIcons.idCard),
        label: const Text('OAuth Provider'),
        placeholder: const Text("Your OAuth Provider"),
      ),
    ];
  }

  List<Widget> _addCardFields() {
    return [
      Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => ShadSelectFormField<CardIssuer>(
                minWidth: constraints.maxWidth,
                key: ValueKey("cardIssuer"),
                controller: _cardIssuerController,
                label: const Text("Card Issuer"),
                placeholder: const Text("Card Issuer"),
                selectedOptionBuilder: (context, value) =>
                    Text(value.toNiceString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                options: CardIssuer.values.map(
                  (c) => ShadOption<CardIssuer>(
                    key: Key('issuer-${c.name}'),
                    value: c,
                    child: Text(c.toNiceString()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ShadInputFormField(
        key: ValueKey("cardHolder"),
        controller: _cardHolderNameController,
        leading: Icon(LucideIcons.user),
        label: const Text('Card Holder Name'),
        placeholder: const Text("Name of Card Holder"),
      ),
      ShadInputFormField(
        key: ValueKey("cardNumber"),
        controller: _cardNumberController,
        leading: Icon(LucideIcons.fileDigit),
        label: const Text('Card Number'),
        placeholder: const Text("Card Number"),
      ),
      Row(
        spacing: sizeXS,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => ShadSelectFormField<int>(
                key: ValueKey("cardExpirationMonth"),
                controller: _cardExpirationMonthController,
                label: const Text("Expiration Month"),
                placeholder: const Text("Expiration Month"),
                minWidth: constraints.maxWidth,
                selectedOptionBuilder: (context, value) =>
                    Text(value.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                options:
                    <int, String>{
                      1: "01 - January",
                      2: "02 - Feburary",
                      3: "03 - March",
                      4: "04 - April",
                      5: "05 - May",
                      6: "06 - June",
                      7: "07 - July",
                      8: "08 - August",
                      9: "09 - September",
                      10: "10 - October",
                      11: "11 - November",
                      12: "12 - December",
                    }.entries.map(
                      (o) => ShadOption<int>(
                        key: Key('expirationMonth-${o.key}'),
                        value: o.key,
                        child: Text(o.value),
                      ),
                    ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => ShadSelectFormField<int>(
                key: ValueKey("cardExpirationYear"),
                controller: _cardExpirationYearController,
                label: const Text("Expiration Year"),
                placeholder: const Text("Expiration Year"),
                minWidth: constraints.maxWidth,
                selectedOptionBuilder: (context, value) =>
                    Text(value.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                options: List.generate(10, (index) => DateTime.now().year + index).map(
                  (o) => ShadOption<int>(
                    key: Key('expirationYear-$o'),
                    value: o,
                    child: Text(o.toString()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Row(
        spacing: sizeXS,
        children: [
          Expanded(
            child: ShadInputFormField(
              key: ValueKey("cardSecurityCode"),
              controller: _cardSecurityCodeController,
              leading: Icon(LucideIcons.lock),
              label: const Text('Card Security Code'),
              placeholder: const Text("Card Security Code"),
              obscureText: _obscureSecrets,
              trailing: SizedBox(
                width: sizeS,
                height: sizeS,
                child: GlyphButton.ghost(
                  tooltip: "Show/hide value",
                  icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
                  onTap: () {
                    setState(() => _obscureSecrets = !_obscureSecrets);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ShadInputFormField(
              key: ValueKey("cardPin"),
              controller: _cardPinController,
              leading: Icon(LucideIcons.lock),
              label: const Text('Card PIN'),
              placeholder: const Text("Card PIN"),
              obscureText: _obscureSecrets,
              trailing: SizedBox(
                width: sizeS,
                height: sizeS,
                child: GlyphButton.ghost(
                  tooltip: "Show/hide value",
                  icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
                  onTap: () {
                    setState(() => _obscureSecrets = !_obscureSecrets);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _addPgpFields() {
    return [
      ShadInputFormField(
        key: ValueKey("pgpPrivateKey"),
        controller: _pgpPrivateKeyController,
        leading: Icon(LucideIcons.lock),
        label: const Text('PGP Private Key'),
        placeholder: const Text("Your PGP Private Key"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
      ShadInputFormField(
        key: ValueKey("pgpPublicKey"),
        controller: _pgpPublicKeyController,
        leading: Icon(LucideIcons.handHelping),
        label: const Text('PGP Public Key'),
        placeholder: const Text("Your PGP Public Key"),
      ),
      ShadInputFormField(
        key: ValueKey("pgpFingerprint"),
        controller: _pgpFingerprintController,
        leading: Icon(LucideIcons.idCard),
        label: const Text('PGP Fingerprint'),
        placeholder: const Text("Your PGP Fingerprint"),
      ),
    ];
  }

  List<Widget> _addSmimeFields() {
    return [
      ShadInputFormField(
        key: ValueKey("smimePrivateKey"),
        controller: _smimePrivateKeyController,
        leading: Icon(LucideIcons.lock),
        label: const Text('S-MIME Private Key'),
        placeholder: const Text("Your S-MIME Private Key"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
      ShadInputFormField(
        key: ValueKey("smimeCertificate"),
        controller: _smimeCertificateController,
        leading: Icon(LucideIcons.idCard),
        label: const Text('S-MIME Certificate'),
        placeholder: const Text("Your S-MIME Certificate"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _addWifiFields() {
    return [
      ShadInputFormField(
        key: ValueKey("wifiSsid"),
        controller: _wifiSsidController,
        leading: Icon(LucideIcons.idCard),
        label: const Text('Wifi SSID'),
        placeholder: const Text("Your Wifi SSID"),
      ),
      ShadInputFormField(
        key: ValueKey("wifiPassword"),
        controller: _wifiPasswordController,
        leading: Icon(LucideIcons.lock),
        label: const Text('Wifi Password'),
        placeholder: const Text("Your Wifi Password"),
        obscureText: _obscureSecrets,
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
                          _wifiPasswordController.text = newPassword;
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
                icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
                onTap: () {
                  setState(() => _obscureSecrets = !_obscureSecrets);
                },
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _addApiFields() {
    return [
      ShadInputFormField(
        key: ValueKey("apiKey"),
        controller: _apiKeyController,
        leading: Icon(LucideIcons.lock),
        label: const Text('API Key'),
        placeholder: const Text("Your API Key"),
        obscureText: _obscureSecrets,
        trailing: SizedBox(
          width: sizeS,
          height: sizeS,
          child: GlyphButton.ghost(
            tooltip: "Show/hide value",
            icon: _obscureSecrets ? LucideIcons.eyeOff : LucideIcons.eye,
            onTap: () {
              setState(() => _obscureSecrets = !_obscureSecrets);
            },
          ),
        ),
      ),
    ];
  }
}
