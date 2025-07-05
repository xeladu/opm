import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/shared/utils/app_config.dart';

class FirebasePasswordRepositoryImpl implements PasswordRepository {
  final FirebaseConfig config;

  FirebasePasswordRepositoryImpl({required this.config});

  CollectionReference<Map<String, dynamic>> _userPasswordEntriesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    return FirebaseFirestore.instance.collection('passwords_${user.uid}');
  }

  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    await _userPasswordEntriesCollection().doc(entry.id).set(entry.toJson());
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    await _userPasswordEntriesCollection().doc(entry.id).update(entry.toJson());
  }

  @override
  Future<void> deletePasswordEntry(String id) async {
    await _userPasswordEntriesCollection().doc(id).delete();
  }

  @override
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    final snapshot = await _userPasswordEntriesCollection().get();
    return snapshot.docs
        .map((doc) => PasswordEntry.fromJson(doc.data()))
        .toList();
  }
}
