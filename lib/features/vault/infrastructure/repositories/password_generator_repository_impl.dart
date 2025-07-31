import 'dart:math';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';

class PasswordGeneratorRepositoryImpl extends PasswordGeneratorRepository {
  static PasswordGeneratorRepositoryImpl? _instance;
  static PasswordGeneratorRepositoryImpl get instance {
    _instance ??= PasswordGeneratorRepositoryImpl._();

    return _instance!;
  }

  PasswordGeneratorRepositoryImpl._();

  // Calculates the amount of special characters and numbers based on the given length.
  // The longer the password should be, the more numbers and special characters it will have.
  int calculateSpecialCount(int length) {
    if (length <= 7) return 1;
    if (length <= 15) return 2;
    if (length <= 31) return 3;
    if (length <= 63) return 4;
    return 5;
  }

  @override
  String generatePassword(
    bool useUppercase,
    bool useLowercase,
    bool useNumbers,
    bool useSpecialChars,
    int length,
  ) {
    final enabledParametersCount = [
      useUppercase,
      useLowercase,
      useNumbers,
      useSpecialChars,
    ].where((entry) => true).length;

    if (enabledParametersCount < 2) {
      throw PasswordGeneratorException(
        "At least 2 parameters need to be enabled for password generation",
      );
    }

    var uppercaseLength = 0;
    var lowercaseLength = 0;
    var numbersLength = 0;
    var specialCharsLength = 0;

    if (useUppercase && useLowercase && useNumbers && useSpecialChars) {
      specialCharsLength = numbersLength = calculateSpecialCount(length);
      lowercaseLength = ((length - specialCharsLength - numbersLength) / 2)
          .floor();
      uppercaseLength =
          length - specialCharsLength - numbersLength - lowercaseLength;
    } else if (!useUppercase && useLowercase && useNumbers && useSpecialChars) {
      specialCharsLength = numbersLength = calculateSpecialCount(length);
      lowercaseLength = length - specialCharsLength - numbersLength;
      uppercaseLength = 0;
    } else if (useUppercase && !useLowercase && useNumbers && useSpecialChars) {
      specialCharsLength = numbersLength = calculateSpecialCount(length);
      lowercaseLength = 0;
      uppercaseLength = length - specialCharsLength - numbersLength;
    } else if (useUppercase && useLowercase && !useNumbers && useSpecialChars) {
      specialCharsLength = calculateSpecialCount(length) * 2;
      numbersLength = 0;
      lowercaseLength = ((length - specialCharsLength - numbersLength) / 2)
          .floor();
      uppercaseLength =
          length - specialCharsLength - numbersLength - lowercaseLength;
    } else if (useUppercase && useLowercase && useNumbers && !useSpecialChars) {
      specialCharsLength = 0;
      numbersLength = calculateSpecialCount(length) * 2;
      lowercaseLength = ((length - specialCharsLength - numbersLength) / 2)
          .floor();
      uppercaseLength =
          length - specialCharsLength - numbersLength - lowercaseLength;
    } else if (!useUppercase &&
        !useLowercase &&
        useNumbers &&
        useSpecialChars) {
      specialCharsLength = (length / 2).floor();
      numbersLength = (length / 2).ceil();
      lowercaseLength = 0;
      uppercaseLength = 0;
    } else if (useUppercase &&
        !useLowercase &&
        !useNumbers &&
        useSpecialChars) {
      specialCharsLength = calculateSpecialCount(length) * 2;
      numbersLength = 0;
      lowercaseLength = 0;
      uppercaseLength = length - specialCharsLength;
    } else if (useUppercase &&
        useLowercase &&
        !useNumbers &&
        !useSpecialChars) {
      specialCharsLength = 0;
      numbersLength = 0;
      lowercaseLength = (length / 2).floor();
      uppercaseLength = (length / 2).ceil();
    } else if (!useUppercase &&
        useLowercase &&
        useNumbers &&
        !useSpecialChars) {
      specialCharsLength = 0;
      numbersLength = calculateSpecialCount(length) * 2;
      lowercaseLength = length - numbersLength;
      uppercaseLength = 0;
    } else if (!useUppercase &&
        useLowercase &&
        !useNumbers &&
        useSpecialChars) {
      specialCharsLength = calculateSpecialCount(length) * 2;
      numbersLength = 0;
      lowercaseLength = length - specialCharsLength;
      uppercaseLength = 0;
    } else if (useUppercase &&
        !useLowercase &&
        useNumbers &&
        !useSpecialChars) {
      specialCharsLength = 0;
      numbersLength = calculateSpecialCount(length) * 2;
      lowercaseLength = 0;
      uppercaseLength = length - numbersLength;
    } else {
      throw PasswordGeneratorException(
        "Unsupported parameter configuration\nuseUppercase => $useUppercase\nuseLowercase => $useLowercase\nuseNumbers => $useNumbers\nuseSpecialChars => $useSpecialChars",
      );
    }

    return _generatePasswordFromParts(
      specialCharsLength,
      numbersLength,
      lowercaseLength,
      uppercaseLength,
    );
  }

  String _generatePasswordFromParts(
    int specialCharsLength,
    int numbersLength,
    int lowercaseLength,
    int uppercaseLength,
  ) {
    final allowedSpecialCharacters = ["!", "@", "#", "\$", "%", "^", "&", "*"];
    final allowedNumbers = List.generate(10, (i) => i.toString());
    final allowedLowercase = List.generate(
      26,
      (i) => String.fromCharCode('a'.codeUnitAt(0) + i),
    );
    final allowedUppercase = List.generate(
      26,
      (i) => String.fromCharCode('A'.codeUnitAt(0) + i),
    );
    final rand = Random.secure();
    final chars = <String>[];
    chars.addAll(
      List.generate(
        specialCharsLength,
        (_) =>
            allowedSpecialCharacters[rand.nextInt(
              allowedSpecialCharacters.length,
            )],
      ),
    );
    chars.addAll(
      List.generate(
        numbersLength,
        (_) => allowedNumbers[rand.nextInt(allowedNumbers.length)],
      ),
    );
    chars.addAll(
      List.generate(
        lowercaseLength,
        (_) => allowedLowercase[rand.nextInt(allowedLowercase.length)],
      ),
    );
    chars.addAll(
      List.generate(
        uppercaseLength,
        (_) => allowedUppercase[rand.nextInt(allowedUppercase.length)],
      ),
    );
    chars
      ..shuffle(rand)
      ..shuffle(rand)
      ..shuffle(rand);
    return chars.join();
  }
}

class PasswordGeneratorException implements Exception {
  final String message;
  PasswordGeneratorException(this.message);
}
