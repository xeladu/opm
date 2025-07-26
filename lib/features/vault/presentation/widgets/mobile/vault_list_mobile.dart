import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultListMobile extends StatelessWidget {
  final List<VaultEntry> passwords;

  const VaultListMobile({
    super.key,
    required this.passwords,
  });

  @override
  Widget build(BuildContext context) {
    if (passwords.isEmpty) {
      return Center(
        child: EmptyList(
          message: "Your vault is empty!\r\nStart by adding your first entry",
        ),
      );
    }

    final leftPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${passwords.length} entries found"),
        SizedBox(height: sizeXS),
        VaultSearchField(),
        SizedBox(height: sizeXS),
        Expanded(
          child: ListView.builder(
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final entry = passwords[index];
              return VaultListEntry(
                entry: entry,
                selected: false,
                isMobile: true,
              );
            },
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(sizeS),
      child: leftPanelContent,
    );
  }
}
