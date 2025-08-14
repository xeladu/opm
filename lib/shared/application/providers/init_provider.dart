import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';

final initProvider = AsyncNotifierProvider.autoDispose<InitState, void>(InitState.new);

class InitState extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    final settings = await ref.read(settingsRepositoryProvider).load();

    ref.read(settingsProvider.notifier).setSettings(settings);
  }
}
