import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/application/providers/all_password_entries_provider.dart';
import 'package:open_password_manager/features/password/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/password/application/providers/password_entry_edit_mode_provider.dart';
import 'package:open_password_manager/features/password/application/providers/selected_password_entry_provider.dart';
import 'package:open_password_manager/features/password/application/use_cases/delete_password_entry.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/features/password/presentation/pages/add_edit_password_entry_page.dart';
import 'package:open_password_manager/features/password/presentation/pages/password_entry_detail_page.dart';
import 'package:open_password_manager/features/password/presentation/widgets/password_list_entry_popup.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
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
class PasswordListEntry extends ConsumerWidget {
  final PasswordEntry entry;
  final bool selected;
  final bool isMobile;

  const PasswordListEntry({
    super.key,
    required this.entry,
    required this.selected,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Offset? tapPosition;

    return ShadDecorator(
      focused: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          tapPosition = details.globalPosition;
        },
        onSecondaryTapDown: (details) {
          tapPosition = details.globalPosition;
        },
        onLongPress: () async => await showPopup(context, ref, tapPosition),
        onSecondaryTap: isMobile
            ? null
            : () async => await showPopup(context, ref, tapPosition),
        onDoubleTap: () async => isMobile
            ? await _handleEditMobile(context, ref, entry)
            : await _handleEditDesktop(ref, entry),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 0,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(entry.name, style: ShadTheme.of(context).textTheme.p),
          subtitle: Text(
            entry.username,
            style: ShadTheme.of(context).textTheme.muted,
          ),
          leading: Icon(
            LucideIcons.earth400,
            size: sizeM,
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
          trailing: isMobile
              ? PasswordListEntryPopup(
                  entry: entry,
                  onSelected: (selection, entry) =>
                      _handlePopupSelection(context, ref, selection, entry),
                )
              : null,
          onTap: () async => await onTap(context, ref),
        ),
      ),
    );
  }

  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    if (isMobile) {
      // TODO navigate to selected entry
    } else {
      final editModeActive = ref.read(addEditModeActiveProvider);
      final hasChanges = ref.read(hasChangesProvider);

      if (editModeActive || hasChanges) {
        // ask for confirmation before leaving the edit mode
        final confirm = await DialogService.showCancelDialog(context);

        if (confirm != true) return;

        ref.read(addEditModeActiveProvider.notifier).setMode(false);
        ref.read(hasChangesProvider.notifier).setHasChanges(false);
      }

      // mark/unmark selected entry
      final currentSelectedEntry = ref.read(selectedPasswordEntryProvider);
      if (currentSelectedEntry == null || currentSelectedEntry != entry) {
        ref
            .read(selectedPasswordEntryProvider.notifier)
            .setPasswordEntry(entry);
      } else {
        ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);
      }
    }
  }

  Future<void> showPopup(
    BuildContext context,
    WidgetRef ref,
    Offset? tapPosition,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = tapPosition ?? Offset.zero;
    final selection = await showMenu<PopupSelection>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: ShadTheme.of(context).radius,
        side: BorderSide(color: Colors.white, width: 1),
      ),
      color: ShadTheme.of(context).cardTheme.backgroundColor,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: PasswordListEntryPopup.menuItems,
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
    PasswordEntry entry,
  ) async {
    switch (selection) {
      case PopupSelection.view:
        isMobile
            ? await _handleViewMobile(context, ref, entry)
            : await _handleViewDesktop(ref, entry);
      case PopupSelection.edit:
        isMobile
            ? await _handleEditMobile(context, ref, entry)
            : await _handleEditDesktop(ref, entry);
      case PopupSelection.delete:
        await _delete(context, ref, entry);
      case PopupSelection.copyUser:
        await _handleCopy(context, ref, entry.username, "User");
      case PopupSelection.copyPassword:
        await _handleCopy(context, ref, entry.password, "Password");
      case PopupSelection.openUrl:
        await _openUrl(entry);
    }
  }

  Future<void> _handleCopy(
    BuildContext context,
    WidgetRef ref,
    String toCopy,
    String item,
  ) async {
    ref.read(clipboardRepositoryProvider).copyToClipboard(toCopy);

    if (context.mounted) {
      ToastService.show(context, "$item copied!");
    }
  }

  Future<void> _openUrl(PasswordEntry entry) async {
    if (entry.urls.isEmpty) return;

    final uri = Uri.tryParse(entry.urls.first);
    if (uri == null) return;

    await launchUrl(uri);
  }

  Future<void> _handleViewDesktop(WidgetRef ref, PasswordEntry entry) async {
    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(entry);
  }

  Future<void> _handleViewMobile(
    BuildContext context,
    WidgetRef ref,
    PasswordEntry entry,
  ) async {
    final updatedOrDeleted = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PasswordEntryDetailPage(entry: entry),
      ),
    );

    if (updatedOrDeleted != null) {
      ref.invalidate(allPasswordEntriesProvider);
    }
  }

  Future<void> _handleEditDesktop(WidgetRef ref, PasswordEntry entry) async {
    ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(entry);
    ref
        .read(addEditModeActiveProvider.notifier)
        .setMode(!ref.read(addEditModeActiveProvider));
  }

  Future<void> _handleEditMobile(
    BuildContext context,
    WidgetRef ref,
    PasswordEntry entry,
  ) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditPasswordEntryPage(
          entry: entry,
          onSave: (updatedEntry) async {
            final repo = ref.read(passwordRepositoryProvider);
            await repo.editPasswordEntry(updatedEntry);
          },
        ),
      ),
    );
    if (updated != null) {
      ref.invalidate(allPasswordEntriesProvider);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PasswordEntry entry,
  ) async {
    final confirm = await DialogService.showDeleteDialog(context);

    if (confirm == true) {
      final repo = ref.read(passwordRepositoryProvider);
      final useCase = DeletePasswordEntry(repo);

      await useCase.call(entry.id);
      ref.read(selectedPasswordEntryProvider.notifier).setPasswordEntry(null);
      ref.invalidate(allPasswordEntriesProvider);
    }
  }
}
