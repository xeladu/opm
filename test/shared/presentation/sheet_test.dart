import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';

void main() {
  group("Sheet", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            child: Text("Sheet me!"),
            onPressed: () => showShadSheet(
              builder: (context) => Sheet(title: "My title", content: Card()),
              context: context,
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.text("My title"), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.text("Save"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
    });

    testWidgets("Test all elements", (tester) async {
      var primaryPressed = false;
      var secondaryPressed = false;

      final sut = Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            child: Text("Sheet me!"),
            onPressed: () => showShadSheet(
              builder: (context) => Sheet(
                title: "My title",
                content: Card(),
                description: "Hello",
                hideSecondaryButton: true,
                primaryButtonCaption: "Press me",
                onPrimaryButtonPressed: () async {
                  primaryPressed = true;

                  return true;
                },
                onSecondaryButtonPressed: () async {
                  secondaryPressed = true;

                  return true;
                },
              ),
              context: context,
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.text("My title"), findsOneWidget);
      expect(find.text("Hello"), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsNothing);
      expect(find.text("Save"), findsNothing);
      expect(find.text("Cancel"), findsNothing);
      expect(find.text("Press me"), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(primaryPressed, isTrue);
      expect(secondaryPressed, isFalse);
    });

    testWidgets("Test sheet closing", (tester) async {
      bool primaryPressed = false;
      bool secondaryPressed = false;
      final sut = Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            child: Text("Sheet me!"),
            onPressed: () async => await showShadSheet(
              builder: (context) => Sheet(
                title: "My title",
                content: Card(),
                onPrimaryButtonPressed: () async {
                  primaryPressed = true;
                  return true;
                },
                onSecondaryButtonPressed: () async {
                  secondaryPressed = true;
                  return true;
                },
              ),
              context: context,
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Sheet), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(primaryPressed, isTrue);
      expect(find.byType(Sheet), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Sheet), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(Sheet), findsNothing);
      expect(secondaryPressed, isTrue);
    });

    testWidgets("Test prevent sheet closing", (tester) async {
      bool primaryPressed = false;
      bool secondaryPressed = false;
      final sut = Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            child: Text("Sheet me!"),
            onPressed: () async => await showShadSheet(
              builder: (context) => Sheet(
                title: "My title",
                content: Card(),
                onPrimaryButtonPressed: () async {
                  primaryPressed = true;
                  return false;
                },
                onSecondaryButtonPressed: () async {
                  secondaryPressed = true;
                  return false;
                },
              ),
              context: context,
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Sheet), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(primaryPressed, isTrue);
      expect(find.byType(Sheet), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(Sheet), findsOneWidget);
      expect(secondaryPressed, isTrue);
    });
  });
}
