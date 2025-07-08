abstract class AuthRepository {
  Future<void> createAccount({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> deleteAccount();
}
