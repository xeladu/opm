import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';

void main() {
  group("Loading", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Scaffold(body: Loading());

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, [], pump: true));

      expect(find.byType(ShadProgress), findsOneWidget);
      expect(find.text("Loading ..."), findsOneWidget);
    });

    testWidgets("Test custom text", (tester) async {
      final sut = Scaffold(body: Loading(text: "Test"));

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, [], pump: true));

      expect(find.byType(ShadProgress), findsOneWidget);
      expect(find.text("Test"), findsOneWidget);
      expect(find.text("Loading ..."), findsNothing);
    });
  });
}
