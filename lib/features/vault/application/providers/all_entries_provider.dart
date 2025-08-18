import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_loading_state_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/get_all_entries.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';

/// Returns all entries from the database
final allEntriesProvider = AsyncNotifierProvider<AllEntriesState, List<VaultEntry>>(
  AllEntriesState.new,
);

class AllEntriesState extends AsyncNotifier<List<VaultEntry>> {
  @override
  FutureOr<List<VaultEntry>> build() async {
    ref.keepAlive();

    final repo = ref.read(vaultRepositoryProvider);
    final useCase = GetAllEntries(repo);

    final entries = await useCase(
      onUpdate: (info) {
        ref.read(allEntriesLoadingStateProvider.notifier).setState(info);
      },
    );

    ref.invalidate(allEntriesLoadingStateProvider);

    return entries;
  }
}
