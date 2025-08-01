import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';

class FirebaseSaltRepositoryImpl implements SaltRepository {
  final String collectionId;

  const FirebaseSaltRepositoryImpl({required this.collectionId});

  @override
  Future<String?> getUserSalt(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['salt'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUserSalt(String userId, String salt) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(userId)
          .set({
            'salt': salt,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
