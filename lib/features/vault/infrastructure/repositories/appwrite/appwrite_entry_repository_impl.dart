import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:open_password_manager/shared/utils/app_config.dart';

class AppwriteEntryRepositoryImpl implements EntryRepository {
  final Client client;
  final AppwriteConfig config;
  final CryptographyRepository cryptoRepo;
  late Databases _db;

  AppwriteEntryRepositoryImpl({
    required this.client,
    required this.config,
    required this.cryptoRepo,
  }) {
    _db = Databases(client);
  }

  @override
  Future<void> addEntry(VaultEntry entry) async {
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
  Future<void> editEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _db.updateDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: entry.id,
      data: encryptedEntry.toJson(),
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _db.deleteDocument(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
      documentId: id,
    );
  }

  @override
  Future<List<VaultEntry>> getAllEntries() async {
    final docs = await _db.listDocuments(
      databaseId: config.databaseId,
      collectionId: config.collectionId,
    );

    final entries = docs.documents
        .map((doc) => VaultEntry.fromJson(doc.data))
        .toList();

    final list = await Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return list;
  }
}
