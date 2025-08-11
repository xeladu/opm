import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';

class FirebaseCryptoUtilsRepositoryImpl implements CryptoUtilsRepository {
  final String collectionId;

  const FirebaseCryptoUtilsRepositoryImpl({required this.collectionId});

  @override
  Future<CryptoUtils> getCryptoUtils(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(collectionId).doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        return data == null ? CryptoUtils.empty() : CryptoUtils.fromJson(data);
      }

      return CryptoUtils.empty();
    } catch (e) {
      return CryptoUtils.empty();
    }
  }

  @override
  Future<void> saveCryptoUtils(String userId, CryptoUtils utils) async {
    try {
      await FirebaseFirestore.instance.collection(collectionId).doc(userId).set({
        'salt': utils.salt,
        'encMek': utils.encryptedMasterKey,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
