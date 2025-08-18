import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/use_cases/import_vault.dart';
import 'package:open_password_manager/shared/application/providers/file_picker_service_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/sheets/import_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group("ImportSheet", () {
    late MockFilePickerService mockFilePickerService;

    setUp(() {
      mockFilePickerService = MockFilePickerService();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ImportSheet(
                  onSelected: (_, _) async {
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

      expect(find.byType(ImportSheet), findsOneWidget);
      expect(find.text("Open Password Manager"), findsOneWidget);
      expect(find.text(" - no file selected - "), findsOneWidget);
      expect(find.byType(PrimaryButton), findsNWidgets(2));
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.text("Import"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
    });

    testWidgets("Test import data", (tester) async {
      ImportProvider? importProvider;
      String? fileContent;

      when(mockFilePickerService.pickFile()).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ImportSheet(
                  onSelected: (provider, content) async {
                    importProvider = provider;
                    fileContent = content;
                    return true;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("LastPass"));
      await tester.pumpAndSettle();

      expect(find.text("LastPass"), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(importProvider, ImportProvider.lastPass);
      expect(fileContent, isNotEmpty);
      expect(find.byType(ImportSheet), findsNothing);
    });

    testWidgets("Test pick and clear file", (tester) async {
      when(mockFilePickerService.pickFile()).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ImportSheet(
                  onSelected: (_, _) async {
                    return true;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("folder/subfolder"), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is GlyphButton && w.icon == LucideIcons.trash),
      );
      await tester.pumpAndSettle();

      expect(find.text(" - no file selected - "), findsOneWidget);
    });

    testWidgets("Test import without file", (tester) async {
      ImportProvider? importProvider;
      String? fileContent;

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ImportSheet(
                  onSelected: (provider, content) async {
                    importProvider = provider;
                    fileContent = content;
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

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ShadToast), findsOneWidget);
      expect(importProvider, isNull);
      expect(fileContent, isNull);
      expect(find.byType(ImportSheet), findsOneWidget);
    });

    testWidgets("Test running import", (tester) async {
      when(mockFilePickerService.pickFile()).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => ImportSheet(
                  onSelected: (provider, content) async {
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

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("folder/subfolder"), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pump();

      expect(find.byType(Loading), findsOneWidget);
      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
