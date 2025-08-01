import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/shared/presentation/settings/color_scheme_setting.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('ColorSchemeSetting', () {
    testWidgets('Test default values', (tester) async {
      final sut = Scaffold(body: ColorSchemeSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.byType(ShadSelect<ColorSchemeObject>), findsOneWidget);
      expect(find.text("Neutral color scheme"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ColorSchemeSetting)),
      );

      expect(
        containerProvider.read(appSettingsProvider).darkColorScheme,
        ShadNeutralColorScheme.dark(),
      );
      expect(
        containerProvider.read(appSettingsProvider).lightColorScheme,
        ShadNeutralColorScheme.light(),
      );
    });

    testWidgets('Test value selection', (tester) async {
      final sut = Scaffold(body: ColorSchemeSetting());
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.tap(find.text("Neutral color scheme"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Rose color scheme", skipOffstage: false));
      await tester.pumpAndSettle();
      
      expect(find.text("Rose color scheme"), findsOneWidget);

      final containerProvider = ProviderScope.containerOf(
        tester.element(find.byType(ColorSchemeSetting)),
      );

      expect(
        containerProvider.read(appSettingsProvider).darkColorScheme,
        ShadRoseColorScheme.dark(),
      );
      expect(
        containerProvider.read(appSettingsProvider).lightColorScheme,
        ShadRoseColorScheme.light(),
      );
    });
  });
}
