import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:open_password_manager/shared/utils/app_config.dart';

class AppwritePasswordRepositoryImpl implements PasswordRepository {
  final Client client;
  final AppwriteConfig config;
  final CryptographyRepository cryptoRepo;
  late Databases _db;

  AppwritePasswordRepositoryImpl({
    required this.client,
    required this.config,
    required this.cryptoRepo,
  }) {
    _db = Databases(client);
  }

  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    final account = Account(client);
    final user = await account.get();
    final userId = user.$id;
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _db.createDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: entry.id,
      data: encryptedEntry.toJson(),
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _db.updateDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: entry.id,
      data: encryptedEntry.toJson(),
    );
  }

  @override
  Future<void> deletePasswordEntry(String id) async {
    await _db.deleteDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: id,
    );
  }

  @override
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    final docs = await _db.listDocuments(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
    );

    final entries = docs.documents
        .map((doc) => PasswordEntry.fromJson(doc.data))
        .toList();

    return Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );
  }
}
