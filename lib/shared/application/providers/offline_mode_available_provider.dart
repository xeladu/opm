import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';

/// Indicates if offline mode is available to use or not. Offline mode is a special mode to access
/// the app in read-only mode. No vault data can be added, edited, or deleted, but users are still
/// able to use their passwords.
///
/// Requirements:
/// - Auth data is cached (usually cached after sign in)
/// - Vault data is cached (usually cached after decryption)
/// - Crypto utils are cached (usually cached after crypto service initialization)
final offlineModeAvailableProvider =
    AsyncNotifierProvider.autoDispose<OfflineModeAvailableState, bool>(
      OfflineModeAvailableState.new,
    );

class OfflineModeAvailableState extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    // contains cached auth information to perform a sign in
    final offlineAuthData = await ref.read(storageServiceProvider).loadOfflineAuthData();

    // contains cached cryptographic utilities to decrypt the cached vault
    final offlineCryptUtils = await ref.read(storageServiceProvider).loadOfflineCryptoUtils();

    // contains cached vault entries to allow read access
    final offlineVaultData = await ref.read(storageServiceProvider).loadOfflineVaultData();

    return offlineAuthData.salt.isNotEmpty &&
        offlineAuthData.email.isNotEmpty &&
        offlineCryptUtils.encryptedMasterKey.isNotEmpty &&
        offlineCryptUtils.salt.isNotEmpty &&
        offlineVaultData.isNotEmpty;
  }
}
