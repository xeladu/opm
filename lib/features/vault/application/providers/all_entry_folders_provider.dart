import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/folder.dart';

/// Returns all folders of all entries from the database
final allEntryFoldersProvider = AsyncNotifierProvider<AllEntryFoldersState, List<Folder>>(
  AllEntryFoldersState.new,
);

class AllEntryFoldersState extends AsyncNotifier<List<Folder>> {
  @override
  FutureOr<List<Folder>> build() async {
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
          .map((kv) => Folder(name: kv.key, entryCount: kv.value))
          .toList();

      groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return groups;
    } catch (_) {
      return <Folder>[];
    }
  }

  void addFolder(String newFolder) {
    final copy = List<Folder>.from(state.requireValue).toList();
    copy.add(Folder(name: newFolder, entryCount: 0));

    copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    state = AsyncValue.data(copy);
  }
}
