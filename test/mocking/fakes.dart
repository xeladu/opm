import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/shared/application/providers/offline_mode_available_provider.dart';

class FakeFilterQueryState extends FilterQueryState {
  final String query;
  FakeFilterQueryState(this.query);

  @override
  String build() {
    return query;
  }
}

class FakeBiometricAuthAvailableState extends BiometricAuthAvailableState {
  final bool value;
  FakeBiometricAuthAvailableState(this.value);

  @override
  bool build() {
    return value;
  }
}

class FakeSettingState extends SettingsState {
  final Settings value;
  FakeSettingState(this.value);

  @override
  Settings build() {
    return value;
  }
}

class FakeOfflineModeAvailableState extends OfflineModeAvailableState {
  final bool value;
  FakeOfflineModeAvailableState(this.value);

  @override
  bool build() {
    return value;
  }
}
