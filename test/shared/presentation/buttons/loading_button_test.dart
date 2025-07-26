import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';

import '../../../helper/app_setup.dart';

void main() {
  group('LoadingButton', () {
    testWidgets('Test primary loading button', (tester) async {
      final sut = Scaffold(body: LoadingButton.primary());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.text('Please wait'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
    });

    testWidgets('Test secondary loading button', (tester) async {
      final sut = Scaffold(body: LoadingButton.secondary(caption: 'Wait'));

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.text('Wait'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ShadButton), findsOneWidget);
    });
  });
}
