import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Failed to create account');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Failed to sign in');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }
    // Supabase does not allow users to delete themselves directly from client SDK
    // You may want to sign out the user instead, or call a custom function on your backend
    await Supabase.instance.client.auth.signOut();
    throw UnimplementedError(
      'Delete account is not supported from client SDK.',
    );
  }

  @override
  Future<OpmUser> getCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      return OpmUser(id: user!.id, user: user.email!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
