import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/password_generator_repository_impl.dart';

void main() {
  final repo = PasswordGeneratorRepositoryImpl.instance;

  group('calculateSpecialCount', () {
    test('returns 1 for length <= 7', () {
      expect(repo.calculateSpecialCount(7), 1);
      expect(repo.calculateSpecialCount(1), 1);
    });
    test('returns 2 for length <= 15', () {
      expect(repo.calculateSpecialCount(8), 2);
      expect(repo.calculateSpecialCount(15), 2);
    });
    test('returns 3 for length <= 31', () {
      expect(repo.calculateSpecialCount(16), 3);
      expect(repo.calculateSpecialCount(31), 3);
    });
    test('returns 4 for length <= 63', () {
      expect(repo.calculateSpecialCount(32), 4);
      expect(repo.calculateSpecialCount(63), 4);
    });
    test('returns 5 for length > 63', () {
      expect(repo.calculateSpecialCount(64), 5);
      expect(repo.calculateSpecialCount(100), 5);
    });
  });

  group('generatePassword', () {
    test('throws if less than 2 character sets enabled', () {
      expect(
        () => repo.generatePassword(true, false, false, false, 10),
        throwsA(isA<PasswordGeneratorException>()),
      );
      expect(
        () => repo.generatePassword(false, true, false, false, 10),
        throwsA(isA<PasswordGeneratorException>()),
      );
      expect(
        () => repo.generatePassword(false, false, true, false, 10),
        throwsA(isA<PasswordGeneratorException>()),
      );
      expect(
        () => repo.generatePassword(false, false, false, true, 10),
        throwsA(isA<PasswordGeneratorException>()),
      );
    });

    test('all sets enabled', () {
      final pw = repo.generatePassword(true, true, true, true, 16);
      expect(pw.length, 16);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('lowercase, numbers, special', () {
      final pw = repo.generatePassword(false, true, true, true, 12);
      expect(pw.length, 12);
      expect(pw.contains(RegExp(r'[A-Z]')), isFalse);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, numbers, special', () {
      final pw = repo.generatePassword(true, false, true, true, 12);
      expect(pw.length, 12);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isFalse);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, lowercase, special', () {
      final pw = repo.generatePassword(true, true, false, true, 12);
      expect(pw.length, 12);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isFalse);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, lowercase, numbers', () {
      final pw = repo.generatePassword(true, true, true, false, 12);
      expect(pw.length, 12);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isFalse);
    });

    test('numbers, special only', () {
      final pw = repo.generatePassword(false, false, true, true, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isFalse);
      expect(pw.contains(RegExp(r'[a-z]')), isFalse);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, special only', () {
      final pw = repo.generatePassword(true, false, false, true, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isFalse);
      expect(pw.contains(RegExp(r'[0-9]')), isFalse);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, lowercase only', () {
      final pw = repo.generatePassword(true, true, false, false, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isFalse);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isFalse);
    });

    test('lowercase, numbers only', () {
      final pw = repo.generatePassword(false, true, true, false, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isFalse);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isFalse);
    });

    test('lowercase, special only', () {
      final pw = repo.generatePassword(false, true, false, true, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isFalse);
      expect(pw.contains(RegExp(r'[a-z]')), isTrue);
      expect(pw.contains(RegExp(r'[0-9]')), isFalse);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isTrue);
    });

    test('uppercase, numbers', () {
      final pw = repo.generatePassword(true, false, true, false, 10);
      expect(pw.length, 10);
      expect(pw.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pw.contains(RegExp(r'[a-z]')), isFalse);
      expect(pw.contains(RegExp(r'[0-9]')), isTrue);
      expect(pw.contains(RegExp(r'[!@#\$%\^&*]')), isFalse);
    });
  });
}
