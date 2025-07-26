import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to create account');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in');
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('No user signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to delete account');
    }
  }

  @override
  Future<OpmUser> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      return OpmUser(id: user!.uid, user: user.email!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to retrieve account');
    }
  }
}
