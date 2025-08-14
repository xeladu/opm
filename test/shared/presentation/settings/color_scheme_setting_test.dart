import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/settings/color_scheme_setting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group('ColorSchemeSetting', () {
    late MockSettingsRepository mockSettingsRepository;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
    });

    testWidgets('Test default values', (tester) async {
      final sut = Scaffold(body: ColorSchemeSetting());
      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      expect(find.byType(ShadSelect<ColorSchemeObject>), findsOneWidget);
      expect(find.text("Neutral color scheme"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ColorSchemeSetting)),
      );

      expect(
        containerProvider.read(settingsProvider).darkColorScheme,
        ShadNeutralColorScheme.dark(),
      );
      expect(
        containerProvider.read(settingsProvider).lightColorScheme,
        ShadNeutralColorScheme.light(),
      );
    });

    testWidgets('Test value selection', (tester) async {
      final sut = Scaffold(body: ColorSchemeSetting());

      when(mockSettingsRepository.save(any)).thenAnswer((_) => Future.value());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        ]),
      );

      await tester.tap(find.text("Neutral color scheme"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Rose color scheme", skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text("Rose color scheme"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ColorSchemeSetting)),
      );

      expect(containerProvider.read(settingsProvider).darkColorScheme, ShadRoseColorScheme.dark());
      expect(
        containerProvider.read(settingsProvider).lightColorScheme,
        ShadRoseColorScheme.light(),
      );
    });
  });
}
