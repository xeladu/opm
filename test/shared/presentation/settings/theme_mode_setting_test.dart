import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/settings/theme_mode_setting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
  });

  group('ThemeModeSetting', () {
    testWidgets('Test default values', (tester) async {
      final sut = Scaffold(body: ThemeModeSetting());
      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      expect(find.byType(ShadSelect<ThemeMode>), findsOneWidget);
      expect(find.text("System mode"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ThemeModeSetting)),
      );

      expect(containerProvider.read(settingsProvider).themeMode, ThemeMode.system);
    });

    testWidgets('Test value selection', (tester) async {
      final sut = Scaffold(body: ThemeModeSetting());

      when(mockSettingsRepository.save(any)).thenAnswer((_) => Future.value());
      
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        ]),
      );

      await tester.tap(find.text("System mode"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Light mode", skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text("Light mode"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ThemeModeSetting)),
      );

      expect(containerProvider.read(settingsProvider).themeMode, ThemeMode.light);
    });
  });
}
