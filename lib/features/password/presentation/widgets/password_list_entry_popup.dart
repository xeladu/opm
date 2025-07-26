import 'package:flutter/material.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordListEntryPopup extends StatelessWidget {
  final Function(PopupSelection, PasswordEntry) onSelected;
  final PasswordEntry entry;

  const PasswordListEntryPopup({
    super.key,
    required this.onSelected,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupSelection>(
      icon: Icon(LucideIcons.ellipsis),
      shape: RoundedRectangleBorder(
        borderRadius: ShadTheme.of(context).radius,
        side: BorderSide(color: Colors.white, width: 1),
      ),
      color: ShadTheme.of(context).cardTheme.backgroundColor,
      onSelected: (selection) => onSelected(selection, entry),
      itemBuilder: (context) => menuItems,
    );
  }

  static List<PopupMenuEntry<PopupSelection>> get menuItems => [
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.copyUser,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.copy), Text('Copy username')],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.copyPassword,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.copy), Text('Copy password')],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.openUrl,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.externalLink), Text('Open URL')],
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.view,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.view), Text('View')],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.edit,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.pen), Text('Edit')],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: PopupSelection.delete,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(LucideIcons.delete), Text('Delete')],
      ),
    ),
  ];
}

enum PopupSelection { copyUser, copyPassword, openUrl, view, edit, delete }
