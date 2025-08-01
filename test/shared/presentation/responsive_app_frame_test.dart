import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';

import '../../helper/app_setup.dart';
import '../../helper/display_size.dart';

void main() {
  group("ResponsiveAppFrame", () {
    testWidgets("Test default elements", (tester) async {
      final sut = ResponsiveAppFrame(content: Card());
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets("Test mobile elements", (tester) async {
      await DisplaySizeHelper.setSize(
        tester,
        DisplaySizes.sizes.entries.first.value,
      );

      final sut = ResponsiveAppFrame(
        mobileContent: Text("mobile"),
        mobileButton: FloatingActionButton(
          child: Text("mobile"),
          onPressed: () {},
        ),
        desktopContent: Text("desktop"),
        desktopButton: FloatingActionButton(
          child: Text("desktop"),
          onPressed: () {},
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.text("mobile"), findsNWidgets(2));
      expect(find.byType(GlyphButton), findsOneWidget);
      expect(find.byType(UserMenu), findsOneWidget);
    });

    testWidgets("Test desktop elements", (tester) async {
      await DisplaySizeHelper.setSize(
        tester,
        DisplaySizes.sizes.entries.last.value,
      );

      final sut = ResponsiveAppFrame(
        mobileContent: Text("mobile"),
        mobileButton: FloatingActionButton(
          child: Text("mobile"),
          onPressed: () {},
        ),
        desktopContent: Text("desktop"),
        desktopButton: FloatingActionButton(
          child: Text("desktop"),
          onPressed: () {},
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.text("desktop"), findsNWidgets(2));
      expect(find.byType(GlyphButton), findsNothing);
      expect(find.byType(UserMenu), findsOneWidget);
    });

    testWidgets("Test mobile search field", (tester) async {
      await DisplaySizeHelper.setSize(
        tester,
        DisplaySizes.sizes.entries.first.value,
      );

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),
        mobileButton: FloatingActionButton(
          child: Text("mobile"),
          onPressed: () {},
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      final providerContainer = ProviderScope.containerOf(
        tester.element(find.byType(ResponsiveAppFrame)),
      );

      expect(find.byType(GlyphButton), findsOneWidget);
      expect(providerContainer.read(showSearchFieldProvider), isFalse);

      await tester.tap(find.byType(GlyphButton));
      await tester.pumpAndSettle();

      expect(find.byType(GlyphButton), findsOneWidget);
      expect(providerContainer.read(showSearchFieldProvider), isTrue);
    });
  });
}
