import 'package:mockito/annotations.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/device_auth_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';

@GenerateMocks([
  AuthRepository,
  DeviceAuthRepository,
  EntryRepository,
  CryptographyRepository,
  ClipboardRepository,
  SaltRepository,
  PasswordGeneratorRepository,
])
void main() {}
