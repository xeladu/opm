import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/shared/presentation/settings/theme_mode_setting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('ThemeModeSetting', () {
    testWidgets('Test default values', (tester) async {
      final sut = Scaffold(body: ThemeModeSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pump();
      expect(find.byType(ShadSelect<ThemeMode>), findsOneWidget);
      expect(find.text("System mode"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ThemeModeSetting)),
      );

      expect(
        containerProvider.read(appSettingsProvider).themeMode,
        ThemeMode.system,
      );
    });

    testWidgets('Test value selection', (tester) async {
      final sut = Scaffold(body: ThemeModeSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pump();
      await tester.tap(find.text("System mode"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Light mode", skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text("Light mode"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ThemeModeSetting)),
      );

      expect(
        containerProvider.read(appSettingsProvider).themeMode,
        ThemeMode.light,
      );
    });
  });
}
