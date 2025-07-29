import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VaultListPage extends ConsumerStatefulWidget {
  const VaultListPage({super.key});

  @override
  ConsumerState<VaultListPage> createState() => _State();
}

class _State extends ConsumerState<VaultListPage> {
  @override
  Widget build(BuildContext context) {
    final allPasswords = ref.watch(allEntriesProvider);
    final filterQuery = ref.watch(filterQueryProvider);

    return allPasswords.when(
      loading: () => const ShadProgress(),
      error: (error, stackTrace) => Text(error.toString()),
      data: (passwords) {
        if (passwords.isEmpty) {
          return ResponsiveAppFrame(
            title: "Your vault",
            content: Center(
              child: EmptyList(
                message:
                    "Your vault is empty!\r\nStart by adding your first entry",
              ),
            ),
            mobileButton: ShadTooltip(
              builder: (context) => Text("Add new entry"),
              child: FloatingActionButton(
                onPressed: () async {
                  await NavigationService.goTo(
                    context,
                    AddEditVaultEntryPage(
                      onSave: () => ref.invalidate(allEntriesProvider),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
        }

        final filteredPasswords = filterQuery.isEmpty
            ? passwords
            : passwords.where((entry) {
                return entry.name.toLowerCase().contains(filterQuery) ||
                    entry.username.toLowerCase().contains(filterQuery) ||
                    entry.urls.any(
                      (url) => url.toLowerCase().contains(filterQuery),
                    );
              }).toList();

        return ResponsiveAppFrame(
          title: "Your vault",
          mobileContent: VaultListMobile(passwords: filteredPasswords),
          desktopContent: Padding(
            padding: const EdgeInsets.all(sizeXS),
            child: VaultListDesktop(passwords: filteredPasswords),
          ),
          mobileButton: ShadTooltip(
            builder: (context) => Text("Add new entry"),
            child: FloatingActionButton(
              onPressed: () async {
                await NavigationService.goTo(
                  context,
                  AddEditVaultEntryPage(
                    onSave: () => ref.invalidate(allEntriesProvider),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

typedef FilterFunction = void Function(String);
