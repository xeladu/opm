import 'package:open_password_manager/shared/domain/entities/credentials.dart';

abstract class DeviceAuthRepository {
  Future<bool> isSupported();
  Future<Credentials> authenticate();
  Future<bool> hasStoredCredentials();
}
