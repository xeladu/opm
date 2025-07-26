import 'package:mockito/annotations.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

@GenerateMocks([AuthRepository, CryptographyRepository, ClipboardRepository])
void main() {}
