import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';
import '../../helper/test_data_generator.dart';
import '../../mocking/mocks.mocks.dart';

void main() {
  group("Dialog service", () {
    late MockVaultRepository mockVaultRepository;
    setUp(() {
      mockVaultRepository = MockVaultRepository();
    });

    Future<void> pumpDialog(WidgetTester tester, String type, Function(dynamic) onClose) async {
      final sut = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => ElevatedButton(
                child: Text("Sheet me!"),
                onPressed: () async {
                  switch (type) {
                    case "cancel":
                      final result = await DialogService.showCancelDialog(context);
                      onClose(result);
                      break;
                    case "delete":
                      final result = await DialogService.showDeleteDialog(context);
                      onClose(result);
                      break;
                    case "biometrics":
                      final result = await DialogService.showBiometricsSetupConfirmation(context);
                      onClose(result);
                      break;
                    case "folder":
                      final result = await DialogService.showFolderCreationDialog(context, ref);
                      onClose(result);
                      break;
                  }
                },
              ),
            ),
          ),
        ),
      );

      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);
    }

    Future<void> pumpCancelDialog(WidgetTester tester, Function(bool?) onClose) async {
      await pumpDialog(tester, "cancel", (res) => onClose(res));
    }

    Future<void> pumpDeleteDialog(WidgetTester tester, Function(bool?) onClose) async {
      await pumpDialog(tester, "delete", (res) => onClose(res));
    }

    Future<void> pumpFolderDialog(WidgetTester tester, Function(String?) onClose) async {
      await pumpDialog(tester, "folder", (res) => onClose(res));
    }

    Future<void> pumpBiometricsDialog(WidgetTester tester, Function(bool?) onClose) async {
      await pumpDialog(tester, "biometrics", (res) => onClose(res));
    }

    testWidgets("Test cancel dialog", (tester) async {
      await pumpCancelDialog(tester, (_) {});

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Leave"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Stay"),
        findsOneWidget,
      );
      expect(find.text("Unsaved Changes"), findsOneWidget);
    });

    testWidgets("Test cancel dialog abort", (tester) async {
      bool? result;
      await pumpCancelDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets("Test cancel dialog confirm", (tester) async {
      bool? result;
      await pumpCancelDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets("Test biometrics dialog", (tester) async {
      await pumpBiometricsDialog(tester, (_) {});

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Enable"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Skip for now"),
        findsOneWidget,
      );
      expect(find.text("Biometrics Authentication"), findsOneWidget);
    });

    testWidgets("Test biometrics dialog abort", (tester) async {
      bool? result;
      await pumpBiometricsDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets("Test biometrics dialog confirm", (tester) async {
      bool? result;
      await pumpBiometricsDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets("Test delete dialog", (tester) async {
      await pumpDeleteDialog(tester, (_) {});

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Delete"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Cancel"),
        findsOneWidget,
      );
      expect(find.text("Delete Entry"), findsOneWidget);
    });

    testWidgets("Test delete dialog abort", (tester) async {
      bool? result;
      await pumpDeleteDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets("Test delete dialog confirm", (tester) async {
      bool? result;
      await pumpDeleteDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets("Test folder dialog", (tester) async {
      await pumpFolderDialog(tester, (_) {});

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Add"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Cancel"),
        findsOneWidget,
      );
      expect(find.text("Create new folder"), findsOneWidget);
    });

    testWidgets("Test folder dialog abort", (tester) async {
      String? result;
      await pumpFolderDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), "new folder");
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(result, null);
    });

    testWidgets("Test folder dialog confirm", (tester) async {
      String? result;
      await pumpFolderDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), "new folder");
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(result, "new folder");
    });

    testWidgets("Test folder dialog no input confirm", (tester) async {
      String? result;
      await pumpFolderDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text("Please enter a name!"), findsOneWidget);
      expect(result, null);
    });

    testWidgets("Test folder dialog existing input confirm", (tester) async {
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.vaultEntry(folder: "folder1"),
          TestDataGenerator.vaultEntry(folder: "folder2"),
        ]),
      );

      String? result;
      await pumpFolderDialog(tester, (res) => result = res);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), "folder1");
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text("This folder already exists!"), findsOneWidget);
      expect(result, null);
    });
  });
}
