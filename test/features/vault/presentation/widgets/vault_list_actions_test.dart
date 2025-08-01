import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("VaultListActions", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(body: VaultListActions(onAdd: () {}, enabled: true)),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(SecondaryButton), findsOneWidget);
    });

    testWidgets("Test actions", (tester) async {
      bool clicked = false;
      final sut = Material(
        child: Scaffold(
          body: VaultListActions(
            onAdd: () {
              clicked = true;
            },
            enabled: true,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();
      expect(clicked, true);
    });

    testWidgets("Test actions when disabled", (tester) async {
      bool clicked = false;
      final sut = Material(
        child: Scaffold(
          body: VaultListActions(
            onAdd: () {
              clicked = true;
            },
            enabled: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();
      expect(clicked, false);
    });
  });
}
