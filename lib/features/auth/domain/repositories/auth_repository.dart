import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';

abstract class AuthRepository {
  Future<void> createAccount({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<OpmUser> getCurrentUser();
}
