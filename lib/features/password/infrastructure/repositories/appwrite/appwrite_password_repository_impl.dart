import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/utils/app_config.dart';

class AppwritePasswordRepositoryImpl implements PasswordRepository {
  final Client client;
  final AppwriteConfig config;
  late Databases _db;

  AppwritePasswordRepositoryImpl({required this.client, required this.config}) {
    _db = Databases(client);
  }

  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    await _db.createDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: entry.id,
      data: entry.toJson(),
    );
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    await _db.updateDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: entry.id,
      data: entry.toJson(),
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
    return docs.documents
        .map((doc) => PasswordEntry.fromJson(doc.data))
        .toList();
  }
}
