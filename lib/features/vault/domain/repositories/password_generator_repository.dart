abstract class PasswordGeneratorRepository {
  String generatePassword(
    bool useUppercase,
    bool useLowercase,
    bool useNumbers,
    bool useSpecialChars,
    int length,
  );
}
