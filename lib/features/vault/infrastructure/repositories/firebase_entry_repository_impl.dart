import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/exceptions/database_exception.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:open_password_manager/shared/domain/entities/app_config.dart';

class FirebaseEntryRepositoryImpl implements VaultRepository {
  final FirebaseConfig config;
  final CryptographyRepository cryptoRepo;

  FirebaseEntryRepositoryImpl({required this.config, required this.cryptoRepo});

  CollectionReference<Map<String, dynamic>> _userPasswordEntriesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw DatabaseException('No user signed in');
    }

    return FirebaseFirestore.instance.collection('${config.vaultCollectionPrefix}_${user.uid}');
  }

  @override
  Future<void> addEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _userPasswordEntriesCollection().doc(entry.id).set(encryptedEntry.toJson());
  }

  @override
  Future<void> editEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _userPasswordEntriesCollection().doc(entry.id).update(encryptedEntry.toJson());
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _userPasswordEntriesCollection().doc(id).delete();
  }

  @override
  Future<List<VaultEntry>> getAllEntries({
    Function(String info, double? progress)? onUpdate,
  }) async {
    final snapshot = await _userPasswordEntriesCollection().get();
    final entries = snapshot.docs.map((doc) => VaultEntry.fromJson(doc.data())).toList();

    if (onUpdate != null) {
      onUpdate("${entries.length} entries loaded ...", null);
    }

    final list = <VaultEntry>[];
    for (var i = 0; i < entries.length; i++) {
      list.add(await entries[i].decrypt(cryptoRepo.decrypt));

      if (onUpdate != null) {
        onUpdate("Decrypting entry $i of ${entries.length} ...", i / entries.length);
      }
      await Future.delayed(Duration.zero);
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (onUpdate != null) {
      onUpdate("Sorting data ...", null);
    }

    return list;
  }

  @override
  Future<void> deleteAllEntries() async {
    final colRef = _userPasswordEntriesCollection();

    while (true) {
      final snapshot = await colRef.limit(100).get();
      final docs = snapshot.docs;
      if (docs.isEmpty) return;

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final doc in docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      // Give Firestore a short breather on very large collections
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
