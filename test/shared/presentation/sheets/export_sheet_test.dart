import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/application/use_cases/export_vault.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/sheets/export_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group("ExportSheet", () {
    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ExportSheet(
                  onSelected: (option) async {
                    return true;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);
      expect(find.text("JSON"), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.text("Export"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
    });

    testWidgets("Test selection change", (tester) async {
      ExportOption? result;

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ExportSheet(
                  onSelected: (option) async {
                    result = option;
                    return true;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);

      await tester.tap(find.text("JSON"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("CSV"));
      await tester.pumpAndSettle();

      expect(find.text("CSV"), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(result, ExportOption.csv);
    });

    testWidgets("Test running import", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ExportSheet(
                  onSelected: (option) async {
                    await Future.delayed(Duration(milliseconds: 100));
                    return true;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Export"));
      await tester.pump();

      expect(find.byType(Loading), findsOneWidget);
      expect(find.byType(ExportSheet), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
