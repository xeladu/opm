import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('GlyphButton', () {
    testWidgets('Test standard button style', (tester) async {
      final sut = Scaffold(
        body: GlyphButton(
          icon: Icons.remove,
          onTap: () {},
          enabled: true,
          tooltip: "abc",
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
      expect(find.byType(ShadTooltip), findsOneWidget);
    });

    testWidgets('Test ghost button style', (tester) async {
      final sut = Scaffold(
        body: GlyphButton(
          icon: Icons.remove,
          onTap: () {},
          enabled: true,
          tooltip: "abc",
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
      expect(find.byType(ShadTooltip), findsOneWidget);
    });

    testWidgets('Test important button style', (tester) async {
      final sut = Scaffold(
        body: GlyphButton.important(
          icon: Icons.remove,
          onTap: () {},
          enabled: true,
          tooltip: "abc",
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
      expect(find.byType(ShadTooltip), findsOneWidget);
    });
  });
}
