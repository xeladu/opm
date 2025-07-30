import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSettings extends Equatable {
  final ShadColorScheme darkColorScheme;
  final ShadColorScheme lightColorScheme;
  final ThemeMode themeMode;

  const AppSettings({
    required this.darkColorScheme,
    required this.lightColorScheme,
    required this.themeMode,
  });

  AppSettings.empty()
    : this(
        lightColorScheme: ShadNeutralColorScheme.light(),
        darkColorScheme: ShadNeutralColorScheme.dark(),
        themeMode: ThemeMode.system,
      );

  AppSettings copyWith({
    ShadColorScheme? newDarkColorScheme,
    ShadColorScheme? newLightColorScheme,
    ThemeMode? newThemeMode,
  }) {
    return AppSettings(
      darkColorScheme: newDarkColorScheme ?? darkColorScheme,
      lightColorScheme: newLightColorScheme ?? lightColorScheme,
      themeMode: newThemeMode ?? themeMode,
    );
  }

  @override
  List<Object?> get props => [darkColorScheme, lightColorScheme, themeMode];
}
