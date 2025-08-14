import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Settings extends Equatable {
  final ShadColorScheme darkColorScheme;
  final ShadColorScheme lightColorScheme;
  final ThemeMode themeMode;
  final bool biometricAuthEnabled;

  const Settings({
    required this.darkColorScheme,
    required this.lightColorScheme,
    required this.themeMode,
    required this.biometricAuthEnabled,
  });

  Settings.empty()
    : this(
        lightColorScheme: ShadNeutralColorScheme.light(),
        darkColorScheme: ShadNeutralColorScheme.dark(),
        themeMode: ThemeMode.system,
        biometricAuthEnabled: false,
      );

  Settings copyWith({
    ShadColorScheme? newDarkColorScheme,
    ShadColorScheme? newLightColorScheme,
    ThemeMode? newThemeMode,
    bool? newBiometricAuthEnabled,
  }) {
    return Settings(
      darkColorScheme: newDarkColorScheme ?? darkColorScheme,
      lightColorScheme: newLightColorScheme ?? lightColorScheme,
      themeMode: newThemeMode ?? themeMode,
      biometricAuthEnabled: newBiometricAuthEnabled ?? biometricAuthEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'darkColorScheme': _colorSchemeToName(darkColorScheme),
    'lightColorScheme': _colorSchemeToName(lightColorScheme),
    'themeMode': themeMode.index,
    'biometricAuthEnabled': biometricAuthEnabled,
  };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    darkColorScheme: ShadColorScheme.fromName(json['darkColorScheme']),
    lightColorScheme: ShadColorScheme.fromName(json['lightColorScheme']),
    themeMode: ThemeMode.values[json['themeMode'] as int],
    biometricAuthEnabled: json['biometricAuthEnabled'] as bool,
  );

  @override
  List<Object?> get props => [darkColorScheme, lightColorScheme, themeMode, biometricAuthEnabled];

  String _colorSchemeToName(ShadColorScheme scheme) {
    return scheme.runtimeType
        .toString()
        .toLowerCase()
        .replaceAll("shad", "")
        .replaceAll("colorscheme", "");
  }
}
