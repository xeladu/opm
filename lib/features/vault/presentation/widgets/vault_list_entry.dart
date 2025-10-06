import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/delete_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_entry_detail_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/favicon.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry_popup.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/popup_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// A list entry widget for displaying a password record in the password manager UI.
///
/// Displays the password entry's name, username, and an icon. The entry can be selected,
/// tapped, or long-pressed/right-clicked to trigger additional actions via a popup menu.
///
/// Popup menu behavior:
/// - On mobile (isMobile = true):
///   - The popup menu is shown by a long press on the entry.
///   - The trailing widget is an inline popup button (three dots menu).
///   - Right-click is not available.
/// - On desktop (isMobile = false):
///   - The popup menu is shown by right-clicking (secondary tap) on the entry.
///   - The trailing widget is null (no inline popup button).
///   - Long press also triggers the popup for accessibility.
///
/// The popup menu is positioned at the mouse/tap location for a native feel.
class VaultListEntry extends ConsumerWidget {
  final VaultEntry entry;
  final bool selected;
  final bool isMobile;

  const VaultListEntry({
    super.key,
    required this.entry,
    required this.selected,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Offset? tapPosition;

    return GestureDetector(
      key: ValueKey("entry-${entry.id}"),
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        tapPosition = details.globalPosition;
      },
      onSecondaryTapDown: (details) {
        tapPosition = details.globalPosition;
      },
      onLongPress: () async => await showPopup(context, ref, tapPosition),
      onSecondaryTap: isMobile ? null : () async => await showPopup(context, ref, tapPosition),
      onDoubleTap: () async => isMobile
          ? await _handleEditMobile(context, ref, entry)
          : await _handleEditDesktop(context, ref, entry),
      onTap: () async => await onTap(context, ref),
      child: ListTile(
        minTileHeight: minVaultEntryTileHeight,
        shape: RoundedRectangleBorder(borderRadius: ShadTheme.of(context).radius),
        tileColor: selected ? ShadTheme.of(context).colorScheme.accent : null,
        contentPadding: EdgeInsets.symmetric(horizontal: sizeXS),
        splashColor: Colors.transparent,
        minVerticalPadding: 0,
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(
          entry.name,
          style: ShadTheme.of(context).textTheme.p,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: entry.username.isEmpty
            ? null
            : Text(
                entry.username,
                style: ShadTheme.of(context).textTheme.muted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        leading: Favicon(entry: entry),
        trailing: isMobile
            ? VaultListEntryPopup(
                entry: entry,
                onSelected: (selection, entry) =>
                    _handlePopupSelection(context, ref, selection, entry),
              )
            : null,
      ),
    );
  }

  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    if (isMobile) {
      await NavigationService.goTo(context, VaultEntryDetailPage(entry: entry));
    } else {
      final confirmed = await _confirmAction(context, ref);
      if (!confirmed) return;

      // mark/unmark selected entry
      final currentSelectedEntry = ref.read(selectedEntryProvider);
      if (currentSelectedEntry == null || currentSelectedEntry != entry) {
        ref.read(selectedEntryProvider.notifier).setEntry(entry);
      } else {
        ref.read(selectedEntryProvider.notifier).setEntry(null);
      }
    }
  }

  Future<void> showPopup(BuildContext context, WidgetRef ref, Offset? tapPosition) async {
    final selection = await PopupService.showPopup<PopupSelection>(
      context,
      VaultListEntryPopupItemsBuilder(type: entry.type).build(),
      tapPosition ?? Offset.zero,
    );

    if (selection != null) {
      if (context.mounted) {
        _handlePopupSelection(context, ref, selection, entry);
      }
    }
  }

  Future<void> _handlePopupSelection(
    BuildContext context,
    WidgetRef ref,
    PopupSelection selection,
    VaultEntry entry,
  ) async {
    switch (selection) {
      case PopupSelection.view:
        isMobile
            ? await _handleViewMobile(context, ref, entry)
            : await _handleViewDesktop(context, ref, entry);
        break;
      case PopupSelection.edit:
        isMobile
            ? await _handleEditMobile(context, ref, entry)
            : await _handleEditDesktop(context, ref, entry);
        break;
      case PopupSelection.delete:
        await _delete(context, ref, entry);
        break;
      case PopupSelection.copyUser:
        await _handleCopy(context, ref, entry.username, "User");
        break;
      case PopupSelection.copyPassword:
        await _handleCopy(context, ref, entry.password, "Password");
        break;
      case PopupSelection.openUrl:
        await _openUrl(entry);
        break;
      case PopupSelection.copySshPrivateKey:
        await _handleCopy(context, ref, entry.sshPrivateKey, "SSH private key");
        break;
      case PopupSelection.copySshPublicKey:
        await _handleCopy(context, ref, entry.sshPrivateKey, "SSH public key");
        break;
      case PopupSelection.copySshFingerprint:
        await _handleCopy(context, ref, entry.sshFingerprint, "SSH fingerprint");
        break;
      case PopupSelection.copyCardHolderName:
        await _handleCopy(context, ref, entry.cardHolderName, "Card holder");
        break;
      case PopupSelection.copyCardNumber:
        await _handleCopy(context, ref, entry.cardNumber, "Card number");
        break;
      case PopupSelection.copyCardExpirationMonth:
        await _handleCopy(context, ref, entry.cardExpirationMonth, "Card expiration month");
        break;
      case PopupSelection.copyCardExpirationYear:
        await _handleCopy(context, ref, entry.cardExpirationYear, "Card expiration year");
        break;
      case PopupSelection.copyCardSecurityCode:
        await _handleCopy(context, ref, entry.cardSecurityCode, "Card security code");
        break;
      case PopupSelection.copyCardIssuer:
        await _handleCopy(context, ref, entry.cardIssuer, "Card issuer");
        break;
      case PopupSelection.copyCardPin:
        await _handleCopy(context, ref, entry.cardPin, "Card pin");
        break;
      case PopupSelection.copyOauthProvider:
        await _handleCopy(context, ref, entry.oauthProvider, "OAuth provider");
        break;
      case PopupSelection.copyOauthClientId:
        await _handleCopy(context, ref, entry.oauthClientId, "OAuth client id");
        break;
      case PopupSelection.copyOauthAccessToken:
        await _handleCopy(context, ref, entry.oauthAccessToken, "OAuth access token");
        break;
      case PopupSelection.copyOauthRefreshToken:
        await _handleCopy(context, ref, entry.oauthRefreshToken, "OAuth refresh token");
        break;
      case PopupSelection.copyWifiSsid:
        await _handleCopy(context, ref, entry.wifiSsid, "WiFi SSID");
        break;
      case PopupSelection.copyWifiPassword:
        await _handleCopy(context, ref, entry.wifiPassword, "WiFi password");
        break;
      case PopupSelection.copyPgpPrivateKey:
        await _handleCopy(context, ref, entry.pgpPrivateKey, "GPG private key");
        break;
      case PopupSelection.copyPgpPublicKey:
        await _handleCopy(context, ref, entry.pgpPublicKey, "PGP public key");
        break;
      case PopupSelection.copyPgpFingerprint:
        await _handleCopy(context, ref, entry.pgpFingerprint, "PGP fingerprint");
        break;
      case PopupSelection.copySmimeCertificate:
        await _handleCopy(context, ref, entry.smimeCertificate, "S/MIME certificate");
        break;
      case PopupSelection.copySmimePrivateKey:
        await _handleCopy(context, ref, entry.smimePrivateKey, "S/MIME private key");
        break;
      case PopupSelection.copyApiKey:
        await _handleCopy(context, ref, entry.apiKey, "API key");
        break;
    }
  }

  Future<void> _handleCopy(BuildContext context, WidgetRef ref, String toCopy, String item) async {
    ref.read(clipboardRepositoryProvider).copyToClipboard(toCopy);

    if (context.mounted) {
      ToastService.show(context, "$item copied!");
    }
  }

  Future<void> _openUrl(VaultEntry entry) async {
    if (entry.urls.isEmpty) return;

    final uri = Uri.tryParse(entry.urls.first);
    if (uri == null) return;

    await launchUrl(uri);
  }

  Future<void> _handleViewDesktop(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    final confirmed = await _confirmAction(context, ref);
    if (!confirmed) return;

    ref.read(selectedEntryProvider.notifier).setEntry(entry);
  }

  Future<void> _handleViewMobile(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    final confirmed = await _confirmAction(context, ref);
    if (!confirmed) return;

    if (context.mounted) {
      await NavigationService.goTo(context, VaultEntryDetailPage(entry: entry));
    }
  }

  Future<void> _handleEditDesktop(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    if (noConnection(ref)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }
    if (noConnection(ref)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }
    final confirmed = await _confirmAction(context, ref);
    if (!confirmed) return;

    ref.read(selectedEntryProvider.notifier).setEntry(entry);
    ref.read(addEditModeActiveProvider.notifier).setMode(!ref.read(addEditModeActiveProvider));
  }

  Future<void> _handleEditMobile(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    if (noConnection(ref)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

    final confirmed = await _confirmAction(context, ref);
    if (!confirmed) return;

    if (context.mounted) {
      await NavigationService.goTo(
        context,
        AddEditVaultEntryPage(
          template: VaultEntryType.values.firstWhere(
            (t) => t.name.toLowerCase().contains(entry.type.toLowerCase()),
          ),
          entry: entry,
          onSave: () async {
            ref.invalidate(allEntriesProvider);
          },
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    if (noConnection(ref)) {
      await DialogService.showNoConnectionDialog(context);
      return;
    }

    final confirmed = await _confirmAction(context, ref);
    if (!confirmed) return;

    if (context.mounted) {
      final confirm = await DialogService.showDeleteDialog(context);

      if (confirm == true) {
        final repo = ref.read(vaultRepositoryProvider);
        final useCase = DeleteEntry(repo);

        await useCase.call(entry.id);
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

  Future<bool> _confirmAction(BuildContext context, WidgetRef ref) async {
    final editModeActive = ref.read(addEditModeActiveProvider);
    final hasChanges = ref.read(hasChangesProvider);

    if ((editModeActive && hasChanges) || hasChanges) {
      // ask for confirmation before leaving the edit mode
      final confirm = await DialogService.showCancelDialog(context);

      if (confirm != true) {
        return false;
      }
    }

    ref.read(addEditModeActiveProvider.notifier).setMode(false);
    ref.read(hasChangesProvider.notifier).setHasChanges(false);

    return true;
  }

  bool noConnection(WidgetRef ref) {
    return ref.read(noConnectionProvider);
  }
}
