import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';

class AppwriteCryptoUtilsRepositoryImpl implements CryptoUtilsRepository {
  final Client client;
  final String databaseId;
  final String collectionId;
  late Databases _db;

  AppwriteCryptoUtilsRepositoryImpl({
    required this.client,
    required this.databaseId,
    required this.collectionId,
  }) {
    _db = Databases(client);
  }

  @override
  Future<CryptoUtils> getCryptoUtils(String userId) async {
    try {
      final document = await _db.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
      );

      return CryptoUtils.fromJson(document.data);
    } catch (e) {
      return CryptoUtils.empty();
    }
  }

  @override
  Future<void> saveCryptoUtils(String userId, CryptoUtils utils) async {
    try {
      await _db.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
        data: {'salt': utils.salt, 'encMek': utils.encryptedMasterKey},
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
