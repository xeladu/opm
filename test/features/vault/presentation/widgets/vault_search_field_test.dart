import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../mocking/fakes.dart';

void main() {
  group("VaultSearchField", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(child: Scaffold(body: VaultSearchField()));
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInput), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets("Test existing query", (tester) async {
      final sut = Material(child: Scaffold(body: VaultSearchField()));
      await AppSetup.pumpPage(tester, sut, [
        filterQueryProvider.overrideWith(() => FakeFilterQueryState("abc")),
      ]);

      expect(find.byType(ShadInput), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(VaultSearchField)),
      );
      expect(container.read(filterQueryProvider), "abc");
    });

    testWidgets("Test clear icon", (tester) async {
      final sut = Material(child: Scaffold(body: VaultSearchField()));
      await AppSetup.pumpPage(tester, sut, []);

      await tester.enterText(find.byType(ShadInput), "abc");
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(VaultSearchField)),
      );
      expect(container.read(filterQueryProvider), "abc");
      expect(find.byIcon(LucideIcons.x), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pump();

      expect(container.read(filterQueryProvider), "");
      expect(find.text("abc"), findsNothing);
    });
  });
}
