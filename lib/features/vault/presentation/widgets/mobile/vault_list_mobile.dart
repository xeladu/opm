import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultListMobile extends ConsumerWidget {
  final List<VaultEntry> passwords;
  final bool vaultEmpty;

  const VaultListMobile({
    super.key,
    required this.passwords,
    required this.vaultEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearchField = ref.watch(showSearchFieldProvider);

    return Padding(
      padding: const EdgeInsets.all(sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSearchField) ...[
            Text("${passwords.length} entries found"),
            SizedBox(height: sizeXS),
            VaultSearchField(),
          ],
          SizedBox(height: sizeXS),
          Expanded(
            child: vaultEmpty
                ? Center(
                    child: EmptyList(
                      message:
                          "Your vault is empty!\r\nStart by adding your first entry",
                    ),
                  )
                : ListView.builder(
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
