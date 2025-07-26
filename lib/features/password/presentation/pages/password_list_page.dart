import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/application/providers/all_password_entries_provider.dart';
import 'package:open_password_manager/features/password/application/providers/password_filter_query_provider.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/features/password/presentation/pages/add_edit_password_entry_page.dart';
import 'package:open_password_manager/features/password/presentation/widgets/desktop/password_list_desktop.dart';
import 'package:open_password_manager/features/password/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/password/presentation/widgets/mobile/password_list_mobile.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordListPage extends ConsumerStatefulWidget {
  const PasswordListPage({super.key});

  @override
  ConsumerState<PasswordListPage> createState() => _State();
}

class _State extends ConsumerState<PasswordListPage> {
  @override
  Widget build(BuildContext context) {
    final allPasswords = ref.watch(allPasswordEntriesProvider);
    final filterQuery = ref.watch(passwordFilterQueryProvider);

    return allPasswords.when(
      loading: () => const ShadProgress(),
      error: (error, stackTrace) => Text(error.toString()),
      data: (passwords) {
        if (passwords.isEmpty) {
          return Center(
            child: EmptyList(
              message:
                  "Your vault is empty!\r\nStart by adding your first entry",
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
          mobileContent: PasswordListMobile(passwords: filteredPasswords),
          desktopContent: Padding(
            padding: const EdgeInsets.all(sizeXS),
            child: PasswordListDesktop(passwords: filteredPasswords),
          ),
          mobileButton: FloatingActionButton(
            onPressed: () async {
              final added = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditPasswordEntryPage(
                    onSave: (entry) async {
                      final repo = ref.read(passwordRepositoryProvider);
                      await repo.addPasswordEntry(entry);
                    },
                  ),
                ),
              );
              if (added != null) {
                ref.invalidate(allPasswordEntriesProvider);
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

typedef FilterFunction = void Function(String);
