import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('Test elements', (tester) async {
      final sut = Scaffold(
        body: PrimaryButton(caption: 'Test', icon: Icons.add, onPressed: () {}),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
    });
  });
}
