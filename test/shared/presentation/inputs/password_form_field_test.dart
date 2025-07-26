import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('PasswordFormField', () {
    testWidgets('Test obscure toggle', (tester) async {
      final sut = PasswordFormField();
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      final eyeOnButton = find.byIcon(LucideIcons.eye);
      final eyeOffButton = find.byIcon(LucideIcons.eyeOff);

      // hidden
      expect(eyeOffButton, findsOneWidget);
      expect(eyeOnButton, findsNothing);

      await tester.tap(eyeOffButton);
      await tester.pump();

      // visible
      expect(eyeOnButton, findsOneWidget);
      expect(eyeOffButton, findsNothing);

      await tester.tap(eyeOnButton);
      await tester.pump();

      // hidden
      expect(eyeOffButton, findsOneWidget);
      expect(eyeOnButton, findsNothing);
    });

    testWidgets('Test empty value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final sut = Scaffold(
        body: Form(key: formKey, child: PasswordFormField()),
      );
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('Test non empty value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final sut = Scaffold(
        body: Form(key: formKey, child: PasswordFormField()),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.enterText(find.byType(ShadInputFormField), 'password123');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsNothing);
    });
  });
}
