import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/type_folder.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';

/// Returns all type groups of all entries from the database
final allTypeGroupsProvider = AsyncNotifierProvider<AllTypeGroupsState, List<TypeFolder>>(
  AllTypeGroupsState.new,
);

class AllTypeGroupsState extends AsyncNotifier<List<TypeFolder>> {
  @override
  FutureOr<List<TypeFolder>> build() async {
    try {
      final entries = await ref.watch(allEntriesProvider.future);

      final groups = <TypeFolder>[];
      for (final type in VaultEntryType.values) {
        final count = entries.where((e) => e.type == type.name).length;

        groups.add(TypeFolder(type: type, entryCount: count));
      }

      return groups;
    } catch (_) {
      return <TypeFolder>[];
    }
  }
}
