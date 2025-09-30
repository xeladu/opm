import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';

import '../../../../../helper/app_setup.dart';
import '../../../../../helper/test_data_generator.dart';

void main() {
  group("VaultListMobile", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListMobile(
            entries: [
              TestDataGenerator.randomVaultEntry(),
              TestDataGenerator.randomVaultEntry(),
            ],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(VaultSearchField), findsNothing);
      expect(find.byType(EmptyList), findsNothing);
    });

    testWidgets("Test empty list", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListMobile(
            entries: [
              TestDataGenerator.randomVaultEntry(),
              TestDataGenerator.randomVaultEntry(),
            ],
            vaultEmpty: true,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(VaultListEntry), findsNothing);
      expect(find.byType(VaultSearchField), findsNothing);
      expect(find.byType(EmptyList), findsOneWidget);
    });

    testWidgets("Test search field", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListMobile(
            entries: [
              TestDataGenerator.randomVaultEntry(),
              TestDataGenerator.randomVaultEntry(),
            ],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      final container = tester.container();
      container.read(showSearchFieldProvider.notifier).setState(true);
      await tester.pumpAndSettle();

      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(EmptyList), findsNothing);
    });
  });
}
