import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';

class GeneratePassword {
  final PasswordGeneratorRepository repo;

  GeneratePassword({required this.repo});

  String call(
    bool useUppercase,
    bool useLowercase,
    bool useNumbers,
    bool useSpecialChars,
    int length,
  ) {
    return repo.generatePassword(
      useUppercase,
      useLowercase,
      useNumbers,
      useSpecialChars,
      length,
    );
  }
}
