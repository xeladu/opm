import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/domain/entities/app_settings.dart';

final appSettingsProvider = NotifierProvider<AppSettingsState, AppSettings>(
  AppSettingsState.new,
);

class AppSettingsState extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return AppSettings.empty();
  }

  void setSettings(AppSettings settings) {
    state = settings;
  }
}
