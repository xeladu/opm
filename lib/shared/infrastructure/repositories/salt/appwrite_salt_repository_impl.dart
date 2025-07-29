import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';

class AppwriteSaltRepositoryImpl implements SaltRepository {
  final Client client;
  final String databaseId;
  final String collectionId;
  late Databases _db;

  AppwriteSaltRepositoryImpl({
    required this.client,
    required this.databaseId,
    required this.collectionId,
  }) {
    _db = Databases(client);
  }

  @override
  Future<String?> getUserSalt(String userId) async {
    try {
      // Use the userId directly as the document ID
      final document = await _db.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
      );

      return document.data['salt'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUserSalt(String userId, String salt) async {
    try {
      await _db.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
        data: {
          'salt': salt,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
    } catch (e) {
      rethrow;
    }
  }
}
