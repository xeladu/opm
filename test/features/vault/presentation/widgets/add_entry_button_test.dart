import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_entry_button.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("AddEntryButton", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: Container(),
          floatingActionButton: AddEntryButton(),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditVaultEntryPage), findsOneWidget);
    });
  });
}
