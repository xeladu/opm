import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:appwrite/appwrite.dart';

class AppwriteAuthRepositoryImpl implements AuthRepository {
  final Account _account;

  AppwriteAuthRepositoryImpl(Client client) : _account = Account(client);

  @override
  Future<void> createAccount({required String email, required String password}) async {
    try {
      await _account.create(userId: ID.unique(), email: email, password: password);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to create account');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _account.createEmailPasswordSession(email: email, password: password);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to sign out');
    }
  }

  @override
  Future<OpmUser> getCurrentUser() async {
    try {
      final user = await _account.get();
      return OpmUser(id: user.$id, user: user.email);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to retrieve account');
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      await _account.updateSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to refresh session');
    }
  }

  @override
  Future<bool> isSessionExpired() async {
    final session = await _account.getSession(sessionId: 'current');
    final exprDate = DateTime.parse(session.expire);

    return exprDate.isAfter(DateTime.now());
  }
}
