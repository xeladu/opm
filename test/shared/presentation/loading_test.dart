import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/application/providers/loading_text_state_provider.dart';
import 'package:open_password_manager/shared/application/providers/loading_value_state_provider.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';

void main() {
  group("Loading", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Scaffold(body: Loading(text: "abc", value: 0.5));

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, [], pump: true));

      expect(find.byType(ShadProgress), findsOneWidget);
      expect(find.text("abc"), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is ShadProgress && w.value! <= 0.5 && w.value! >= 0.5),
        findsOneWidget,
      );
    });

    testWidgets("Test with provider", (tester) async {
      final sut = Scaffold(body: Loading());

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, [], pump: true));

      final container = tester.container();
      container.read(loadingTextStateProvider.notifier).setState("abc");
      container.read(loadingValueStateProvider.notifier).setState(0.5);

      await tester.pump();

      expect(find.byType(ShadProgress), findsOneWidget);
      expect(find.text("abc"), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is ShadProgress && w.value! <= 0.5 && w.value! >= 0.5),
        findsOneWidget,
      );
    });
  });
}
