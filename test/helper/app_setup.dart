import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSetup {
  static Future<void> pumpPage(
    WidgetTester tester,
    Widget child,
    List<Override> overrides, {
    bool pump = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: ShadApp(home: child),
      ),
    );
    pump ? await tester.pump() : await tester.pumpAndSettle();
  }
}
