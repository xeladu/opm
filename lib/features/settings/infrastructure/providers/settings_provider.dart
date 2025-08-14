import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';

final settingsProvider = NotifierProvider<SettingsState, Settings>(SettingsState.new);

class SettingsState extends Notifier<Settings> {
  @override
  Settings build() {
    return Settings.empty();
  }

  void setSettings(Settings settings) {
    state = settings;
  }
}
