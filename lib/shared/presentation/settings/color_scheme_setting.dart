import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ColorSchemeSetting extends ConsumerWidget {
  const ColorSchemeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sizeXS,
      children: [
        Text(
          "Choose your color scheme",
          style: ShadTheme.of(context).textTheme.small,
        ),
        ShadSelect<ColorSchemeObject>(
          maxWidth: selectLargeWidth,
          minWidth: selectLargeWidth,
          initialValue: ColorSchemeObject(
            light: ref.read(appSettingsProvider).lightColorScheme,
            dark: ref.read(appSettingsProvider).darkColorScheme,
          ),
          options: colorSchemes.map(
            (item) => ShadOption(value: item, child: Text(_convertName(item))),
          ),
          selectedOptionBuilder: (context, value) => Text(_convertName(value)),
          onChanged: (colorScheme) {
            final settings = ref.read(appSettingsProvider);
            ref
                .read(appSettingsProvider.notifier)
                .setSettings(
                  settings.copyWith(
                    newLightColorScheme: colorScheme!.light,
                    newDarkColorScheme: colorScheme.dark,
                  ),
                );
          },
        ),
      ],
    );
  }

  List<ColorSchemeObject> get colorSchemes => [
    ColorSchemeObject(
      light: ShadBlueColorScheme.light(),
      dark: ShadBlueColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadGrayColorScheme.light(),
      dark: ShadGrayColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadGreenColorScheme.light(),
      dark: ShadGreenColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadNeutralColorScheme.light(),
      dark: ShadNeutralColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadOrangeColorScheme.light(),
      dark: ShadOrangeColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadRedColorScheme.light(),
      dark: ShadRedColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadRoseColorScheme.light(),
      dark: ShadRoseColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadSlateColorScheme.light(),
      dark: ShadSlateColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadStoneColorScheme.light(),
      dark: ShadStoneColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadYellowColorScheme.light(),
      dark: ShadYellowColorScheme.dark(),
    ),
    ColorSchemeObject(
      light: ShadZincColorScheme.light(),
      dark: ShadZincColorScheme.dark(),
    ),
  ];

  String _convertName(ColorSchemeObject scheme) {
    return scheme.dark.runtimeType
        .toString()
        .replaceAll("Shad", "")
        .replaceAll("ColorScheme", " color scheme");
  }
}

class ColorSchemeObject extends Equatable {
  final ShadColorScheme dark;
  final ShadColorScheme light;

  const ColorSchemeObject({required this.dark, required this.light});

  @override
  List<Object?> get props => [dark, light];
}
