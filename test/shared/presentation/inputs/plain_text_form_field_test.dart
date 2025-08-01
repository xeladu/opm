import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/inputs/plain_text_form_field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group('PlainTextFormField', () {
    late MockClipboardRepository mockClipboardRepo;

    setUp(() {
      mockClipboardRepo = MockClipboardRepository();
    });

    testWidgets('Test elements', (tester) async {
      final sut = Scaffold(
        body: PlainTextFormField(
          label: "dummy",
          canCopy: true,
          canToggle: true,
          icon: LucideIcons.personStanding,
          readOnly: true,
          value: "123",
        ),
      );
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.text("123"), findsOneWidget);
      expect(find.text("dummy"), findsOneWidget);
      expect(find.byIcon(LucideIcons.personStanding), findsOneWidget);
      expect(find.byIcon(LucideIcons.copy), findsOneWidget);
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
    });

    testWidgets('Test copy', (tester) async {
      final sut = Scaffold(
        body: PlainTextFormField(label: "dummy", value: "123", canCopy: true),
      );
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          clipboardRepositoryProvider.overrideWithValue(mockClipboardRepo),
        ]),
      );

      expect(find.byIcon(LucideIcons.copy), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.copy));
      await tester.pump();

      verify(mockClipboardRepo.copyToClipboard(any)).called(1);
    });

    testWidgets('Test toggle', (tester) async {
      final sut = Scaffold(
        body: PlainTextFormField(label: "dummy", value: "123", canToggle: true),
      );
      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      final eyeOnButton = find.byIcon(LucideIcons.eye);
      final eyeOffButton = find.byIcon(LucideIcons.eyeOff);

      // hidden
      expect(eyeOffButton, findsOneWidget);
      expect(eyeOnButton, findsNothing);

      await tester.tap(eyeOffButton);
      await tester.pump();

      // visible
      expect(eyeOnButton, findsOneWidget);
      expect(eyeOffButton, findsNothing);

      await tester.tap(eyeOnButton);
      await tester.pump();

      // hidden
      expect(eyeOffButton, findsOneWidget);
      expect(eyeOnButton, findsNothing);
    });
  });
}
