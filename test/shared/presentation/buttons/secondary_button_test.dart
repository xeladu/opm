import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('SecondaryButton', () {
    testWidgets('Test elements', (tester) async {
      final sut = Scaffold(
        body: SecondaryButton(
          caption: 'Secondary',
          icon: Icons.remove,
          onPressed: () {},
          enabled: true,
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
    });

    testWidgets('Test disabled state', (tester) async {
      final sut = Scaffold(
        body: SecondaryButton(
          caption: 'Disabled',
          onPressed: () {
            fail("Tapping should not be possible!");
          },
          enabled: false,
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.tap(find.byType(ShadButton));
      await tester.pump();

      expect(find.text('Disabled'), findsOneWidget);
    });
  });
}
