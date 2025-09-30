import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';

final biometricAuthAvailableProvider =
    AsyncNotifierProvider<BiometricAuthAvailableState, bool>(
      BiometricAuthAvailableState.new,
    );

class BiometricAuthAvailableState extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final biometricAuthRepoProvider = ref.read(biometricAuthRepositoryProvider);
    final authRepoProvider = ref.read(authRepositoryProvider);

    final biometricAuthSupported = await biometricAuthRepoProvider.isSupported();
    final activeSession = !await authRepoProvider.isSessionExpired();
    final hasStoredMasterKey = await ref.read(storageServiceProvider).hasMasterKey();

    return biometricAuthSupported && activeSession && hasStoredMasterKey;
  }
}
