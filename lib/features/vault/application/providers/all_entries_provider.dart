import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/uncache_vault.dart';
import 'package:open_password_manager/shared/application/providers/loading_text_state_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/get_all_entries.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/loading_value_state_provider.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';

/// Returns all entries from the database or the offline cache
final allEntriesProvider = AsyncNotifierProvider<AllEntriesState, List<VaultEntry>>(
  AllEntriesState.new,
);

class AllEntriesState extends AsyncNotifier<List<VaultEntry>> {
  @override
  FutureOr<List<VaultEntry>> build() async {
    ref.keepAlive();
    final storageService = ref.read(storageServiceProvider);
    final cryptoRepo = ref.read(cryptographyRepositoryProvider);
    List<VaultEntry>? entries;

    final isOffline = ref.read(noConnectionProvider);
    if (isOffline) {
      final uncacheVaultUseCase = UncacheVault(storageService, cryptoRepo);
      entries = await uncacheVaultUseCase();
    } else {
      final vaultRepo = ref.read(vaultRepositoryProvider);
      final getAllEntriesUseCase = GetAllEntries(vaultRepo);

      entries = await getAllEntriesUseCase(
        onUpdate: (info, progress) {
          ref.read(loadingTextStateProvider.notifier).setState(info);
          ref.read(loadingValueStateProvider.notifier).setState(progress);
        },
      );

      ref.invalidate(loadingTextStateProvider);
      ref.invalidate(loadingValueStateProvider);

      // cache entries locally
      final cacheVault = CacheVault(storageService, cryptoRepo);
      unawaited(cacheVault(entries));
    }

    return entries;
  }
}
