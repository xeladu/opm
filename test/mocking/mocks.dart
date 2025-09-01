import 'package:mockito/annotations.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/biometric_auth_repository.dart';
import 'package:open_password_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';
import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/application/services/file_picker_service.dart';
import 'package:open_password_manager/shared/application/services/package_info_service.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';

@GenerateMocks([
  AuthRepository,
  BiometricAuthRepository,
  CryptographyRepository,
  CryptoService,
  ClipboardRepository,
  ExportRepository,
  FilePickerService,
  ImportRepository,
  CryptoUtilsRepository,
  SettingsRepository,
  StorageService,
  PackageInfoService,
  PasswordGeneratorRepository,
  VaultRepository,
])
void main() {}
