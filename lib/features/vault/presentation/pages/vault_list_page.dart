import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/active_folder_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/application/providers/loading_text_state_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultListPage extends ConsumerStatefulWidget {
  const VaultListPage({super.key});

  @override
  ConsumerState<VaultListPage> createState() => _State();
}

class _State extends ConsumerState<VaultListPage> {
  @override
  Widget build(BuildContext context) {
    final allEntriesState = ref.watch(allEntriesProvider);

    return allEntriesState.when(
      loading: () =>
          Loading(text: ref.watch(loadingTextStateProvider) ?? "Getting your vault ready"),
      error: (error, stackTrace) => Text(error.toString()),
      data: (allEntries) {
        final filteredEntries = _filterEntries(allEntries);

        return ResponsiveAppFrame(
          title: "Your vault",
          mobileContent: VaultListMobile(
            entries: filteredEntries,
            vaultEmpty: allEntries.isEmpty,
          ),
          desktopContent: Padding(
            padding: const EdgeInsets.all(sizeXS),
            child: VaultListDesktop(entries: filteredEntries, vaultEmpty: allEntries.isEmpty),
          ),
          mobileButton: AddEntryButton(),
        );
      },
    );
  }

  List<VaultEntry> _filterEntries(List<VaultEntry> allEntries) {
    final filterQuery = ref.watch(filterQueryProvider);
    final activeFolder = ref.watch(activeFolderProvider);

    var filteredEntries = filterQuery.isEmpty
        ? allEntries
        : allEntries.where((entry) {
            return entry.name.toLowerCase().contains(filterQuery) ||
                entry.username.toLowerCase().contains(filterQuery) ||
                entry.urls.any((url) => url.toLowerCase().contains(filterQuery));
          }).toList();

    filteredEntries = activeFolder.isEmpty
        ? filteredEntries
        : filteredEntries.where((entry) => entry.folder == activeFolder).toList();

    return filteredEntries;
  }
}
