import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  const SupabaseAuthRepositoryImpl(this.client);

  @override
  Future<void> createAccount({required String email, required String password}) async {
    final response = await client.auth.signUp(email: email, password: password);
    if (response.user == null) {
      throw Exception('Failed to create account');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await client.auth.signInWithPassword(email: email, password: password);
      if (response.user == null) {
        throw Exception('Failed to sign in');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  Future<OpmUser> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      return OpmUser(id: user!.id, user: user.email!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<bool> isSessionExpired() async {
    return client.auth.currentSession == null || client.auth.currentSession!.isExpired;
  }

  @override
  Future<void> refreshSession() async {
    await client.auth.refreshSession();
  }
}
