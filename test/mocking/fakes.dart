import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';

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
