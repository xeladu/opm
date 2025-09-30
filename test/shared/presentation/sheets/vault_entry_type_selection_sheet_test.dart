import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/vault_entry_type_selection_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';

void main() {
  group("VaultEntryTypeSelectionSheet", () {
    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => VaultEntryTypeSelectionSheet(onSelected: (_) {}),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SecondaryButton), findsNWidgets(VaultEntryType.values.length));
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    for (final type in VaultEntryType.values) {
      testWidgets("Test tap '${type.toNiceString()}' element", (tester) async {
        VaultEntryType? selectedType;

        final sut = MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                child: Text("Sheet me!"),
                onPressed: () => showShadSheet(
                  builder: (context) =>
                      VaultEntryTypeSelectionSheet(onSelected: (s) => selectedType = s),
                  context: context,
                ),
              ),
            ),
          ),
        );

        await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == type.toNiceString()),
        );
        await tester.pumpAndSettle();

        expect(selectedType, type);
      });
    }
  });
}
