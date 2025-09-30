import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/custom_folder.dart';

/// Returns all folders of all entries from the database
final allEntryFoldersProvider = AsyncNotifierProvider<AllEntryFoldersState, List<CustomFolder>>(
  AllEntryFoldersState.new,
);

class AllEntryFoldersState extends AsyncNotifier<List<CustomFolder>> {
  @override
  FutureOr<List<CustomFolder>> build() async {
    try {
      final entries = await ref.watch(allEntriesProvider.future);

      final Map<String, int> counts = {};
      for (final e in entries) {
        final g = e.folder.trim();
        if (g.isNotEmpty) {
          counts[g] = (counts[g] ?? 0) + 1;
        }
      }

      final groups = counts.entries
          .map((kv) => CustomFolder(name: kv.key, entryCount: kv.value))
          .toList();

      groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return groups;
    } catch (_) {
      return <CustomFolder>[];
    }
  }

  void addFolder(String newFolder) {
    final copy = List<CustomFolder>.from(state.requireValue).toList();
    copy.add(CustomFolder(name: newFolder, entryCount: 0));

    copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    state = AsyncValue.data(copy);
  }
}
