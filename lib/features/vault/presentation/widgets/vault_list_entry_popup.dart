import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultListEntryPopup extends StatelessWidget {
  final Function(PopupSelection, VaultEntry) onSelected;
  final VaultEntry entry;

  const VaultListEntryPopup({
    super.key,
    required this.onSelected,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ShadTooltip(
      builder: (context) => Text("Show menu"),
      child: PopupMenuButton<PopupSelection>(
        tooltip: "",
        icon: Icon(LucideIcons.ellipsis),
        shape: RoundedRectangleBorder(
          borderRadius: ShadTheme.of(context).radius,
          side: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
        color: ShadTheme.of(context).cardTheme.backgroundColor,
        onSelected: (selection) => onSelected(selection, entry),
        itemBuilder: (context) => menuItems,
      ),
    );
  }

  static List<PopupMenuEntry<PopupSelection>> get menuItems => [
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.copyUser,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.copy, size: sizeS),
          Text('Copy username'),
        ],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.copyPassword,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.copy, size: sizeS),
          Text('Copy password'),
        ],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.openUrl,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.externalLink, size: sizeS),
          Text('Open URL'),
        ],
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.view,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.view, size: sizeS),
          Text('View'),
        ],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.edit,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.pen, size: sizeS),
          Text('Edit'),
        ],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.delete,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.delete, size: sizeS),
          Text('Delete'),
        ],
      ),
    ),
  ];
}

enum PopupSelection { copyUser, copyPassword, openUrl, view, edit, delete }
