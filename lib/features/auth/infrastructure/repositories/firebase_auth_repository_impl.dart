import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> createAccount({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to create account');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in');
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
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

  @override
  Future<bool> isSessionExpired() async {
    return FirebaseAuth.instance.currentUser == null;
  }

  @override
  Future<void> refreshSession() async {
    // not supported, managed by Firebase internally
  }
}
