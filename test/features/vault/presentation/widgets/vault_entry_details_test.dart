import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/shared/presentation/inputs/plain_text_form_field.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/test_data_generator.dart';

void main() {
  group("VaultEntryDetails", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(entry: TestDataGenerator.vaultEntry()),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(7));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-pass"), findsOneWidget);
      expect(find.textContaining("url1"), findsOneWidget);
      expect(find.textContaining("url2"), findsOneWidget);
      expect(find.text("my-user"), findsOneWidget);
    });
  });
}
