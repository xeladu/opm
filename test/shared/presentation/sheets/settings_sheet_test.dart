import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/settings/color_scheme_setting.dart';
import 'package:open_password_manager/shared/presentation/settings/theme_mode_setting.dart';
import 'package:open_password_manager/shared/presentation/sheets/settings_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group("SettingsSheet", () {
    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => SettingsSheet(),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsOneWidget);
      expect(find.byType(ColorSchemeSetting), findsOneWidget);
      expect(find.byType(ThemeModeSetting), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsNothing);
      expect(find.text("Close"), findsOneWidget);
    });
  });
}
