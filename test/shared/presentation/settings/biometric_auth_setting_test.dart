import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/settings/biometric_auth_setting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/fakes.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group('BiometricAuthSetting', () {
    late MockSettingsRepository mockSettingsRepository;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
    });

    testWidgets('Test default values', (tester) async {
      final sut = Scaffold(body: BiometricAuthSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          biometricAuthAvailableProvider.overrideWith(() => FakeBiometricAuthAvailableState(true)),
        ]),
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.byType(ShadCard), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(BiometricAuthSetting)),
      );

      expect(containerProvider.read(settingsProvider).biometricAuthEnabled, false);
      expect(find.textContaining("security risks"), findsOneWidget);
    });

    testWidgets('Test element disabled', (tester) async {
      final sut = Scaffold(body: BiometricAuthSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          biometricAuthAvailableProvider.overrideWith(() => FakeBiometricAuthAvailableState(false)),
        ]),
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.byType(ShadCard), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(BiometricAuthSetting)),
      );

      expect(containerProvider.read(settingsProvider).biometricAuthEnabled, false);

      expect(find.textContaining("not available"), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is ShadSwitch && !w.enabled), findsOneWidget);
    });

    testWidgets('Test switch value', (tester) async {
      final sut = Scaffold(body: BiometricAuthSetting());

      when(mockSettingsRepository.save(any)).thenAnswer((_) => Future.value());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          biometricAuthAvailableProvider.overrideWith(() => FakeBiometricAuthAvailableState(true)),
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        ]),
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.byType(ShadCard), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(BiometricAuthSetting)),
      );

      expect(containerProvider.read(settingsProvider).biometricAuthEnabled, false);
      expect(find.byWidgetPredicate((w) => w is ShadSwitch && !w.value), findsOneWidget);

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(containerProvider.read(settingsProvider).biometricAuthEnabled, true);
      expect(find.byWidgetPredicate((w) => w is ShadSwitch && w.value), findsOneWidget);

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(containerProvider.read(settingsProvider).biometricAuthEnabled, false);
      expect(find.byWidgetPredicate((w) => w is ShadSwitch && !w.value), findsOneWidget);
    });
  });
}
