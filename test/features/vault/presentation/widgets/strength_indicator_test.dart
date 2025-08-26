import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/strength_indicator.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("Strength Indicator", () {
    testWidgets("Test strong password", (tester) async {
      final sut = StrengthIndicator(password: "abc123DEF#+'098");
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byIcon(LucideIcons.shieldCheck), findsOneWidget);
      expect(find.byIcon(LucideIcons.shieldAlert), findsNothing);
      expect(find.byIcon(LucideIcons.shieldPlus), findsNothing);
    });

    testWidgets("Test medium password", (tester) async {
      final sut = StrengthIndicator(password: "abc123DEF");
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byIcon(LucideIcons.shieldCheck), findsNothing);
      expect(find.byIcon(LucideIcons.shieldAlert), findsNothing);
      expect(find.byIcon(LucideIcons.shieldPlus), findsOneWidget);
    });

    testWidgets("Test weak password", (tester) async {
      final sut = StrengthIndicator(password: "abc123");
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byIcon(LucideIcons.shieldCheck), findsNothing);
      expect(find.byIcon(LucideIcons.shieldAlert), findsOneWidget);
      expect(find.byIcon(LucideIcons.shieldPlus), findsNothing);
    });
  });
}
