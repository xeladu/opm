import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  group("VaultListActions", () {
    late MockVaultRepository mockVaultRepository;

    setUp(() {
      mockVaultRepository = MockVaultRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(body: VaultListActions(onAdd: () {}, enabled: true)),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.byType(GlyphButton), findsOneWidget);
    });

    testWidgets("Test actions", (tester) async {
      bool clicked = false;

      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

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
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();
      expect(clicked, true);

      await tester.tap(find.byType(GlyphButton));
      await tester.pumpAndSettle();
      expect(find.byType(ShadSheet), findsOneWidget);
    });

    testWidgets("Test actions when disabled", (tester) async {
      bool clicked = false;

      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

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
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();
      expect(clicked, false);

      await tester.tap(find.byType(GlyphButton));
      await tester.pumpAndSettle();
      expect(find.byType(ShadSheet), findsOneWidget);
    });
  });
}
