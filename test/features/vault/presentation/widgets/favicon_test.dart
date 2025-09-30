import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/favicon.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("Favicon", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Favicon(
        entry: VaultEntry.empty().copyWith(
          type: VaultEntryType.credential.name,
          urls: ["https://google.com"],
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    for (final type in VaultEntryType.values) {
      testWidgets("Test type icon '${type.toNiceString()}'", (tester) async {
        final sut = Favicon(
          entry: VaultEntry.empty().copyWith(type: type.name, urls: []),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.byIcon(type.toIcon()), findsOneWidget);
      });
    }
  });
}
