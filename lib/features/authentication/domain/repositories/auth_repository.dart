import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signUpWithGoogle();
  Future<UserEntity> signInWithFacebook();
  Future<UserEntity> signUpWithFacebook();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
