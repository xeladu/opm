import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultListMobile extends StatelessWidget {
  final List<VaultEntry> passwords;

  const VaultListMobile({super.key, required this.passwords});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${passwords.length} entries found"),
          SizedBox(height: sizeXS),
          VaultSearchField(),
          SizedBox(height: sizeXS),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: sizeXL),
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
      ),
    );
  }
}
