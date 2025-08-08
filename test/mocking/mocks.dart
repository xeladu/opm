import 'package:mockito/annotations.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/device_auth_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';
import 'package:open_password_manager/shared/utils/file_picker_service.dart';

@GenerateMocks([
  AuthRepository,
  DeviceAuthRepository,
  CryptographyRepository,
  ClipboardRepository,
  ExportRepository,
  FilePickerService,
  ImportRepository,
  SaltRepository,
  StorageService,
  PasswordGeneratorRepository,
  VaultRepository,
])
void main() {}
