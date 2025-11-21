import 'package:easacc_task/core/errors/failures.dart';
import 'package:easacc_task/core/utils/pretty_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';
import '../models/user_credentials_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  // Use dependency injection for Firebase Auth
  firebase_auth.FirebaseAuth get _firebaseAuth =>
      GetIt.instance<firebase_auth.FirebaseAuth>();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> signInWithGoogle() async {
    PrettyLogger.info(
      'Repository: Starting Google sign in',
      tag: 'AuthRepository',
    );

    try {
      final credentials = await remoteDataSource.signInWithGoogle();

      if (!credentials.isValid()) {
        throw const AuthFailure('Invalid credentials after Google sign in');
      }

      // Get full user info from Firebase
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthFailure('Firebase user is null after Google sign in');
      }

      final userModel = UserModel.fromFirebaseUser(
        id: firebaseUser.uid,
        email: credentials.email,
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: credentials.authProvider,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);
      await localDataSource.saveCredentials(
        credentials.email,
        null, // No password for social login
        credentials.authProvider,
      );

      PrettyLogger.success(
        'Repository: Google sign in completed',
        data: {
          'email': credentials.email,
          'authProvider': credentials.authProvider,
          'userId': firebaseUser.uid,
        },
        tag: 'AuthRepository',
      );

      return userModel;
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Google sign in failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithGoogle() async {
    PrettyLogger.info(
      'Repository: Starting Google sign up',
      tag: 'AuthRepository',
    );
    // For Firebase, sign up and sign in are the same for social providers
    return signInWithGoogle();
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    PrettyLogger.info(
      'Repository: Starting Facebook sign in',
      tag: 'AuthRepository',
    );

    try {
      final credentials = await remoteDataSource.signInWithFacebook();

      if (!credentials.isValid()) {
        throw const AuthFailure('Invalid credentials after Facebook sign in');
      }

      // Get full user info from Firebase (reload to get latest data)
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthFailure('Firebase user is null after Facebook sign in');
      }

      // Reload user to ensure we have the latest data (including updated email/photo)
      await firebaseUser.reload();
      final updatedUser = _firebaseAuth.currentUser!;

      // Use email from credentials (which was fetched from Facebook if needed)
      // Fallback to Firebase user email if credentials email is empty
      final email = credentials.email.isNotEmpty
          ? credentials.email
          : (updatedUser.email ?? '');

      // Get display name and photo URL from Firebase (which should be updated from Facebook by datasource)
      // The datasource has already updated the Firebase profile with Facebook data
      String? name = updatedUser.displayName;
      String? photoUrl = updatedUser.photoURL;

      // Log to verify we're using the correct photo URL
      final isGooglePhoto =
          photoUrl != null && photoUrl.contains('googleusercontent');
      final isFacebookPhoto =
          photoUrl != null &&
          (photoUrl.contains('fbcdn') || photoUrl.contains('facebook'));

      PrettyLogger.debug(
        'Using user data from Firebase (updated by datasource)',
        data: {
          'name': name,
          'photoUrl': photoUrl,
          'isGooglePhoto': isGooglePhoto,
          'isFacebookPhoto': isFacebookPhoto,
        },
        tag: 'AuthRepository',
      );

      final userModel = UserModel.fromFirebaseUser(
        id: updatedUser.uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
        authProvider: credentials.authProvider,
        createdAt: updatedUser.metadata.creationTime,
        lastLoginAt: updatedUser.metadata.lastSignInTime,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);
      await localDataSource.saveCredentials(
        credentials.email,
        null, // No password for social login
        credentials.authProvider,
      );

      PrettyLogger.success(
        'Repository: Facebook sign in completed',
        data: {
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'authProvider': credentials.authProvider,
          'userId': updatedUser.uid,
        },
        tag: 'AuthRepository',
      );

      return userModel;
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Facebook sign in failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    PrettyLogger.info(
      'Repository: Starting email/password sign in',
      data: {'email': email},
      tag: 'AuthRepository',
    );

    try {
      // Validate credentials before attempting sign in
      final credentialsModel = UserCredentialsModel(
        email: email,
        password: password,
        authProvider: 'email',
      );

      if (!credentialsModel.isValid()) {
        throw const AuthFailure('Invalid email or password format');
      }

      final credentials = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credentials.isValid()) {
        throw const AuthFailure('Invalid credentials after sign in');
      }

      // Get full user info from Firebase
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthFailure('Firebase user is null after sign in');
      }

      final userModel = UserModel.fromFirebaseUser(
        id: firebaseUser.uid,
        email: credentials.email,
        password: credentials.password,
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: credentials.authProvider,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);
      await localDataSource.saveCredentials(
        credentials.email,
        credentials.password,
        credentials.authProvider,
      );

      PrettyLogger.success(
        'Repository: Email/password sign in completed',
        data: {
          'email': credentials.email,
          'authProvider': credentials.authProvider,
        },
        tag: 'AuthRepository',
      );

      return userModel;
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Email/password sign in failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    PrettyLogger.info(
      'Repository: Starting email/password sign up',
      data: {'email': email},
      tag: 'AuthRepository',
    );

    try {
      // Validate credentials before attempting sign up
      final credentialsModel = UserCredentialsModel(
        email: email,
        password: password,
        authProvider: 'email',
      );

      if (!credentialsModel.isValid()) {
        throw const AuthFailure('Invalid email or password format');
      }

      final credentials = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credentials.isValid()) {
        throw const AuthFailure('Invalid credentials after sign up');
      }

      // Get full user info from Firebase
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthFailure('Firebase user is null after sign in');
      }

      final userModel = UserModel.fromFirebaseUser(
        id: firebaseUser.uid,
        email: credentials.email,
        password: credentials.password,
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: credentials.authProvider,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);
      await localDataSource.saveCredentials(
        credentials.email,
        credentials.password,
        credentials.authProvider,
      );

      PrettyLogger.success(
        'Repository: Email/password sign up completed',
        data: {
          'email': credentials.email,
          'authProvider': credentials.authProvider,
        },
        tag: 'AuthRepository',
      );

      return userModel;
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Email/password sign up failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithFacebook() async {
    PrettyLogger.info(
      'Repository: Starting Facebook sign up',
      tag: 'AuthRepository',
    );
    // For Firebase, sign up and sign in are the same for social providers
    return signInWithFacebook();
  }

  @override
  Future<void> signOut() async {
    PrettyLogger.info('Repository: Starting sign out', tag: 'AuthRepository');

    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();

      PrettyLogger.success(
        'Repository: Sign out completed',
        tag: 'AuthRepository',
      );
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Sign out failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // First try to get from remote
      final credentials = await remoteDataSource.getCurrentUser();
      if (credentials != null && credentials.isValid()) {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          final userModel = UserModel.fromFirebaseUser(
            id: firebaseUser.uid,
            email: credentials.email,
            password: credentials.password,
            name: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            authProvider: credentials.authProvider,
            createdAt: firebaseUser.metadata.creationTime,
            lastLoginAt: firebaseUser.metadata.lastSignInTime,
          );
          // Update cache
          await localDataSource.cacheUser(userModel);
          return userModel;
        }
      }

      // If no remote user, try local cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        PrettyLogger.debug(
          'Repository: Retrieved user from cache',
          tag: 'AuthRepository',
        );
      }

      return cachedUser;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Repository: Error getting current user',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((credentials) async {
      if (credentials == null) {
        await localDataSource.clearCache();
        return null;
      }

      if (!credentials.isValid()) {
        PrettyLogger.warning(
          'Repository: Invalid credentials in auth state stream',
          tag: 'AuthRepository',
        );
        return null;
      }

      // Get full user info from Firebase
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        PrettyLogger.warning(
          'Repository: Firebase user is null in auth state stream',
          tag: 'AuthRepository',
        );
        return null;
      }

      final userModel = UserModel.fromFirebaseUser(
        id: firebaseUser.uid,
        email: credentials.email,
        password: credentials.password,
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: credentials.authProvider,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      // Update cache
      await localDataSource.cacheUser(userModel);

      PrettyLogger.debug(
        'Repository: Auth state updated',
        data: {
          'email': credentials.email,
          'authProvider': credentials.authProvider,
        },
        tag: 'AuthRepository',
      );

      return userModel;
    });
  }
}
