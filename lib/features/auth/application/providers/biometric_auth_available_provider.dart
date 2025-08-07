import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/infrastructure/device_auth_repository_provider.dart';

final biometricAuthAvailableProvider =
    AsyncNotifierProvider<BiometricAuthAvailableState, bool>(
      BiometricAuthAvailableState.new,
    );

class BiometricAuthAvailableState extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final deviceAuthRepoProvider = ref.read(deviceAuthRepositoryProvider);
    final biometricAuthSupported = await deviceAuthRepoProvider.isSupported();
    final authCredentialsStored = await deviceAuthRepoProvider
        .hasStoredCredentials();

    return biometricAuthSupported && authCredentialsStored;
  }
}
