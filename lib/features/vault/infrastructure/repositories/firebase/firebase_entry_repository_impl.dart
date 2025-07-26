import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:open_password_manager/shared/utils/app_config.dart';

class FirebaseEntryRepositoryImpl implements EntryRepository {
  final FirebaseConfig config;
  final CryptographyRepository cryptoRepo;

  FirebaseEntryRepositoryImpl({required this.config, required this.cryptoRepo});

  CollectionReference<Map<String, dynamic>> _userPasswordEntriesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    return FirebaseFirestore.instance.collection('passwords_${user.uid}');
  }

  @override
  Future<void> addEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _userPasswordEntriesCollection()
        .doc(entry.id)
        .set(encryptedEntry.toJson());
  }

  @override
  Future<void> editEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await _userPasswordEntriesCollection()
        .doc(entry.id)
        .update(encryptedEntry.toJson());
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _userPasswordEntriesCollection().doc(id).delete();
  }

  @override
  Future<List<VaultEntry>> getAllEntries() async {
    final snapshot = await _userPasswordEntriesCollection().get();
    final entries = snapshot.docs
        .map((doc) => VaultEntry.fromJson(doc.data()))
        .toList();

    final list = await Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return list;
  }
}
