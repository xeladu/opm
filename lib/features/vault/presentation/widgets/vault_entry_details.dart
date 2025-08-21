import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/presentation/inputs/plain_text_form_field.dart';
import 'package:open_password_manager/style/ui.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

class VaultEntryDetails extends StatelessWidget {
  final VaultEntry entry;

  const VaultEntryDetails({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("yyyy/dd/MM, HH:mm:ss");
    final createdAtDate = DateTime.parse(entry.createdAt);
    final updatedAtDate = DateTime.parse(entry.updatedAt);

    return SingleChildScrollView(
      child: Column(
        spacing: sizeXS,
        children: [
          PlainTextFormField.readOnly(label: "Name", value: entry.name),
          PlainTextFormField.readOnly(label: "Username", value: entry.username, canCopy: true),
          PlainTextFormField.readOnly(
            label: "Password",
            value: entry.password,
            canToggle: true,
            canCopy: true,
          ),
          PlainTextFormField.readOnly(label: "URLs", value: entry.urls.join('\n'), maxLines: 3),
          PlainTextFormField.readOnly(label: "Comments", value: entry.comments, maxLines: 2),
          PlainTextFormField.readOnly(label: "Folder", value: entry.folder),
          PlainTextFormField.readOnly(
            label: "Created At",
            value: "${df.format(createdAtDate)} (${timeago.format(createdAtDate, locale: 'en')})",
          ),
          PlainTextFormField.readOnly(
            label: "Updated At",
            value: "${df.format(updatedAtDate)} (${timeago.format(updatedAtDate, locale: 'en')})",
          ),
        ],
      ),
    );
  }
}
