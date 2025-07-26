import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('EmailFormField', () {
    testWidgets('Test empty value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final sut = Scaffold(
        body: Form(key: formKey, child: EmailFormField()),
      );
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('Test invalid value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final sut = Scaffold(
        body: Form(key: formKey, child: EmailFormField()),
      );

      await AppSetup.pumpPage(tester, sut, []);

      await tester.enterText(find.byType(ShadInputFormField), 'someText');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('Test non empty value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final sut = Scaffold(
        body: Form(key: formKey, child: EmailFormField()),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.enterText(find.byType(ShadInputFormField), 'password123');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsNothing);
    });
  });
}
