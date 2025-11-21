import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easacc_task/core/errors/failures.dart';
import 'package:easacc_task/core/utils/pretty_logger.dart';
import '../models/user_credentials_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredentialsModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredentialsModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredentialsModel> signInWithGoogle();
  Future<UserCredentialsModel> signUpWithGoogle();
  Future<UserCredentialsModel> signInWithFacebook();
  Future<UserCredentialsModel> signUpWithFacebook();
  Future<void> signOut();
  Future<UserCredentialsModel?> getCurrentUser();
  Stream<UserCredentialsModel?> get authStateChanges;

  // Additional helper methods
  Future<bool> isGoogleSignInAvailable();
  Future<bool> isFacebookSignInAvailable();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> reauthenticateWithCredential(
    firebase_auth.AuthCredential credential,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Use dependency injection instead of constructor parameters
  firebase_auth.FirebaseAuth get _firebaseAuth =>
      GetIt.instance<firebase_auth.FirebaseAuth>();
  GoogleSignIn get _googleSignIn => GetIt.instance<GoogleSignIn>();
  FacebookAuth get _facebookAuth => GetIt.instance<FacebookAuth>();

  @override
  Future<UserCredentialsModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    PrettyLogger.info(
      'Starting email/password sign in',
      data: {'email': email},
      tag: 'AuthRemoteDataSource',
    );

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('User is null after sign in');
      }

      final userCredentials = UserCredentialsModel.fromFirebaseUser(
        credential.user!,
        password: password,
      );

      PrettyLogger.success(
        'Email/password sign in successful',
        data: {
          'email': userCredentials.email,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Firebase auth error during email/password sign in',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message, 'email': email},
        tag: 'AuthRemoteDataSource',
      );

      String errorMessage = 'Sign in failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'Sign in failed';
      }

      throw AuthFailure(errorMessage);
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Unexpected error during email/password sign in',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserCredentialsModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    PrettyLogger.info(
      'Starting email/password sign up',
      data: {'email': email},
      tag: 'AuthRemoteDataSource',
    );

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('User is null after sign up');
      }

      final userCredentials = UserCredentialsModel.fromFirebaseUser(
        credential.user!,
        password: password,
      );

      PrettyLogger.success(
        'Email/password sign up successful',
        data: {
          'email': userCredentials.email,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Firebase auth error during email/password sign up',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message, 'email': email},
        tag: 'AuthRemoteDataSource',
      );

      String errorMessage = 'Sign up failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Sign up failed';
      }

      throw AuthFailure(errorMessage);
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Unexpected error during email/password sign up',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserCredentialsModel> signInWithGoogle() async {
    PrettyLogger.info('Starting Google sign in', tag: 'AuthRemoteDataSource');

    try {
      // Check if Google Sign-In is available
      final isAvailable = await isGoogleSignInAvailable();
      if (!isAvailable) {
        throw const AuthFailure('Google Sign-In is not available');
      }

      // Trigger the authentication flow
      PrettyLogger.debug(
        'Requesting Google Sign-In',
        tag: 'AuthRemoteDataSource',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        PrettyLogger.warning(
          'Google sign in was cancelled by user',
          tag: 'AuthRemoteDataSource',
        );
        throw const AuthFailure('Google sign in was cancelled');
      }

      PrettyLogger.debug(
        'Google user account obtained',
        data: {
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'id': googleUser.id,
        },
        tag: 'AuthRemoteDataSource',
      );

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      PrettyLogger.debug(
        'Google authentication details obtained',
        data: {
          'hasAccessToken': googleAuth.accessToken != null,
          'hasIdToken': googleAuth.idToken != null,
        },
        tag: 'AuthRemoteDataSource',
      );

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      PrettyLogger.debug(
        'Signing in to Firebase with Google credential',
        tag: 'AuthRemoteDataSource',
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('User is null after Google sign in');
      }

      final userCredentials = UserCredentialsModel.fromFirebaseUser(
        userCredential.user!,
      );

      PrettyLogger.success(
        'Google sign in successful',
        data: {
          'email': userCredentials.email,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Firebase auth error during Google sign in',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message},
        tag: 'AuthRemoteDataSource',
      );

      String errorMessage = 'Google sign in failed';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with a different sign-in method';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid Google credential';
          break;
        default:
          errorMessage = e.message ?? 'Google sign in failed';
      }

      throw AuthFailure(errorMessage);
    } catch (e, stackTrace) {
      if (e is AuthFailure) {
        rethrow;
      }

      PrettyLogger.error(
        'Unexpected error during Google sign in',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure(
        'An unexpected error occurred during Google sign in: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserCredentialsModel> signUpWithGoogle() async {
    // For Firebase, sign up and sign in are the same for social providers
    // Firebase automatically creates an account if it doesn't exist
    PrettyLogger.info('Starting Google sign up', tag: 'AuthRemoteDataSource');
    return signInWithGoogle();
  }

  @override
  Future<UserCredentialsModel> signInWithFacebook() async {
    PrettyLogger.info('Starting Facebook sign in', tag: 'AuthRemoteDataSource');

    try {
      PrettyLogger.debug(
        'Requesting Facebook login',
        tag: 'AuthRemoteDataSource',
      );

      // Attempt to login - this will throw MissingPluginException if plugin isn't registered
      // Request email and public_profile permissions explicitly
      // Use loginBehavior: LoginBehavior.webOnly to ensure proper redirect handling
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      PrettyLogger.debug(
        'Facebook login result',
        data: {
          'status': result.status.toString(),
          'hasAccessToken': result.accessToken != null,
        },
        tag: 'AuthRemoteDataSource',
      );

      if (result.status != LoginStatus.success) {
        PrettyLogger.warning(
          'Facebook sign in failed or was cancelled',
          data: {'status': result.status.toString()},
          tag: 'AuthRemoteDataSource',
        );

        // Check if user is already authenticated in Firebase
        // This can happen if user logged in but cancelled Google Play redirect
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null &&
            currentUser.providerData.any(
              (info) => info.providerId == 'facebook.com',
            )) {
          PrettyLogger.info(
            'User is already authenticated with Facebook, using existing session',
            tag: 'AuthRemoteDataSource',
          );
          final userCredentials = UserCredentialsModel.fromFirebaseUser(
            currentUser,
          );
          return userCredentials;
        }

        throw const AuthFailure('Facebook sign in was cancelled or failed');
      }

      if (result.accessToken == null) {
        throw const AuthFailure('Facebook access token is null');
      }

      // Create a credential from the access token
      // Note: flutter_facebook_auth uses tokenString, not token
      final firebase_auth.OAuthCredential facebookCredential = firebase_auth
          .FacebookAuthProvider.credential(result.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      PrettyLogger.debug(
        'Signing in to Firebase with Facebook credential',
        tag: 'AuthRemoteDataSource',
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        facebookCredential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('User is null after Facebook sign in');
      }

      final firebaseUser = userCredential.user!;

      // Fetch user data from Facebook Graph API (email, name, picture)
      String? email = firebaseUser.email;
      String? name = firebaseUser.displayName;
      String? photoUrl = firebaseUser.photoURL;

      if (result.accessToken != null) {
        try {
          PrettyLogger.debug(
            'Fetching user data from Facebook Graph API',
            tag: 'AuthRemoteDataSource',
          );

          final userData = await _facebookAuth.getUserData();

          // Always try to get email from Facebook (it's more reliable)
          if (userData['email'] != null) {
            final facebookEmail = userData['email'] as String?;
            if (facebookEmail != null && facebookEmail.isNotEmpty) {
              email = facebookEmail;
              PrettyLogger.debug(
                'Fetched email from Facebook Graph API',
                data: {'email': email},
                tag: 'AuthRemoteDataSource',
              );
            }
          }

          // If email is still empty, try to get it from Firebase user
          if ((email == null || email.isEmpty) &&
              firebaseUser.email != null &&
              firebaseUser.email!.isNotEmpty) {
            email = firebaseUser.email;
            PrettyLogger.debug(
              'Using email from Firebase user',
              data: {'email': email},
              tag: 'AuthRemoteDataSource',
            );
          }

          // Always try to get name from Facebook (it's more reliable)
          if (userData['name'] != null) {
            final facebookName = userData['name'] as String?;
            if (facebookName != null && facebookName.isNotEmpty) {
              name = facebookName;
              PrettyLogger.debug(
                'Fetched name from Facebook Graph API',
                data: {'name': name},
                tag: 'AuthRemoteDataSource',
              );
            }
          }

          // Always try to get profile picture from Facebook (it's more reliable)
          // Facebook returns picture as an object with 'data' containing 'url'
          if (userData['picture'] != null) {
            try {
              final pictureData = userData['picture'];
              PrettyLogger.debug(
                'Facebook picture data structure',
                data: {'pictureData': pictureData.toString()},
                tag: 'AuthRemoteDataSource',
              );

              if (pictureData is Map) {
                // Try nested structure: picture.data.url
                if (pictureData['data'] != null) {
                  final pictureDataMap = pictureData['data'] as Map;
                  final facebookPhotoUrl = pictureDataMap['url'] as String?;
                  if (facebookPhotoUrl != null && facebookPhotoUrl.isNotEmpty) {
                    photoUrl = facebookPhotoUrl;
                    PrettyLogger.debug(
                      'Fetched profile picture from Facebook Graph API (nested structure)',
                      data: {'photoUrl': photoUrl},
                      tag: 'AuthRemoteDataSource',
                    );
                  }
                }
                // Try direct structure: picture.url
                else if (pictureData['url'] != null) {
                  final facebookPhotoUrl = pictureData['url'] as String?;
                  if (facebookPhotoUrl != null && facebookPhotoUrl.isNotEmpty) {
                    photoUrl = facebookPhotoUrl;
                    PrettyLogger.debug(
                      'Fetched profile picture from Facebook Graph API (direct structure)',
                      data: {'photoUrl': photoUrl},
                      tag: 'AuthRemoteDataSource',
                    );
                  }
                }
              }
              // If picture is a direct string URL
              else if (pictureData is String && pictureData.isNotEmpty) {
                photoUrl = pictureData;
                PrettyLogger.debug(
                  'Fetched profile picture from Facebook Graph API (string URL)',
                  data: {'photoUrl': photoUrl},
                  tag: 'AuthRemoteDataSource',
                );
              }
            } catch (e) {
              PrettyLogger.warning(
                'Error parsing Facebook picture data',
                data: {'error': e.toString()},
                tag: 'AuthRemoteDataSource',
              );
            }
          }

          // Fallback to Firebase data if Facebook doesn't have it
          if ((name == null || name.isEmpty) &&
              firebaseUser.displayName != null &&
              firebaseUser.displayName!.isNotEmpty) {
            name = firebaseUser.displayName;
            PrettyLogger.debug(
              'Using name from Firebase user',
              data: {'name': name},
              tag: 'AuthRemoteDataSource',
            );
          }

          if ((photoUrl == null || photoUrl.isEmpty) &&
              firebaseUser.photoURL != null &&
              firebaseUser.photoURL!.isNotEmpty) {
            photoUrl = firebaseUser.photoURL;
            PrettyLogger.debug(
              'Using photo URL from Firebase user',
              data: {'photoUrl': photoUrl},
              tag: 'AuthRemoteDataSource',
            );
          }

          // Update Firebase user profile with Facebook data
          // Note: Email update requires reauthentication, so we'll use it from Facebook data directly
          // Always update profile (name and photo) to ensure Facebook data is used
          bool needsUpdate = false;
          String? updateName = name;
          String? updatePhotoUrl = photoUrl;

          // Update name if we have it from Facebook
          if (name != null && name.isNotEmpty) {
            if (firebaseUser.displayName != name) {
              needsUpdate = true;
            } else {
              updateName = null; // Don't update if it's the same
            }
          } else {
            updateName = null;
          }

          // ALWAYS update photo URL if we have it from Facebook (to replace any old Google photo)
          if (photoUrl != null && photoUrl.isNotEmpty) {
            // Force update photo URL to ensure Facebook photo is used, not Google
            needsUpdate = true;
            PrettyLogger.debug(
              'Forcing photo URL update with Facebook photo',
              data: {
                'currentFirebasePhoto': firebaseUser.photoURL,
                'newFacebookPhoto': photoUrl,
              },
              tag: 'AuthRemoteDataSource',
            );
          } else {
            updatePhotoUrl = null;
          }

          if (needsUpdate) {
            await firebaseUser.updateProfile(
              displayName: updateName,
              photoURL: updatePhotoUrl,
            );
            PrettyLogger.debug(
              'Updated Firebase user profile with Facebook data',
              data: {
                'name': updateName,
                'photoUrl': updatePhotoUrl,
                'previousPhotoUrl': firebaseUser.photoURL,
              },
              tag: 'AuthRemoteDataSource',
            );

            // Reload user to get updated data
            await firebaseUser.reload();

            // Verify the update
            final reloadedUser = _firebaseAuth.currentUser;
            if (reloadedUser != null && updatePhotoUrl != null) {
              PrettyLogger.debug(
                'Verified photo URL update',
                data: {
                  'expectedPhotoUrl': updatePhotoUrl,
                  'actualPhotoUrl': reloadedUser.photoURL,
                  'match': reloadedUser.photoURL == updatePhotoUrl,
                },
                tag: 'AuthRemoteDataSource',
              );
            }
          }
        } catch (e) {
          PrettyLogger.warning(
            'Could not fetch user data from Facebook Graph API',
            data: {'error': e.toString()},
            tag: 'AuthRemoteDataSource',
          );
        }
      }

      // Create user credentials with email (or empty if not available)
      final userCredentials = UserCredentialsModel(
        email: email ?? '',
        password: null,
        authProvider: 'facebook',
      );

      PrettyLogger.success(
        'Facebook sign in successful',
        data: {
          'email': userCredentials.email,
          'name': name,
          'photoUrl': photoUrl,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Firebase auth error during Facebook sign in',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message},
        tag: 'AuthRemoteDataSource',
      );

      String errorMessage = 'Facebook sign in failed';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with a different sign-in method';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid Facebook credential';
          break;
        default:
          errorMessage = e.message ?? 'Facebook sign in failed';
      }

      throw AuthFailure(errorMessage);
    } on AuthFailure {
      rethrow;
    } catch (e, stackTrace) {
      // Handle MissingPluginException specifically - this is the main issue
      final errorString = e.toString();
      if (errorString.contains('MissingPluginException') ||
          errorString.contains('No implementation found')) {
        PrettyLogger.error(
          'Facebook Auth plugin not properly registered. This requires a full app rebuild.',
          error: e,
          stackTrace: stackTrace,
          tag: 'AuthRemoteDataSource',
        );
        throw const AuthFailure(
          'Facebook sign in requires a full app restart. Please:\n1. Stop the app completely\n2. Run: flutter clean\n3. Run: flutter pub get\n4. Rebuild and run the app\n\nOr use Email/Google sign in instead.',
        );
      }

      PrettyLogger.error(
        'Unexpected error during Facebook sign in',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure(
        'An unexpected error occurred during Facebook sign in: ${errorString}',
      );
    }
  }

  @override
  Future<UserCredentialsModel> signUpWithFacebook() async {
    // For Firebase, sign up and sign in are the same for social providers
    // Firebase automatically creates an account if it doesn't exist
    PrettyLogger.info('Starting Facebook sign up', tag: 'AuthRemoteDataSource');
    return signInWithFacebook();
  }

  @override
  Future<void> signOut() async {
    PrettyLogger.info('Starting sign out', tag: 'AuthRemoteDataSource');

    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);

      PrettyLogger.success('Sign out successful', tag: 'AuthRemoteDataSource');
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Sign out failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserCredentialsModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        PrettyLogger.debug(
          'No current user found',
          tag: 'AuthRemoteDataSource',
        );
        return null;
      }

      final userCredentials = UserCredentialsModel.fromFirebaseUser(user);

      PrettyLogger.debug(
        'Current user retrieved',
        data: {
          'email': userCredentials.email,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Error getting current user',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      return null;
    }
  }

  @override
  Stream<UserCredentialsModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        PrettyLogger.debug(
          'Auth state changed: User signed out',
          tag: 'AuthRemoteDataSource',
        );
        return null;
      }

      final userCredentials = UserCredentialsModel.fromFirebaseUser(user);

      PrettyLogger.debug(
        'Auth state changed: User signed in',
        data: {
          'email': userCredentials.email,
          'authProvider': userCredentials.authProvider,
        },
        tag: 'AuthRemoteDataSource',
      );

      return userCredentials;
    });
  }

  @override
  Future<bool> isGoogleSignInAvailable() async {
    try {
      // Check if Google Sign-In is configured
      final isSignedIn = await _googleSignIn.isSignedIn();
      PrettyLogger.debug(
        'Google Sign-In availability check',
        data: {'isSignedIn': isSignedIn},
        tag: 'AuthRemoteDataSource',
      );
      return true; // Google Sign-In is available if the package is installed
    } catch (e) {
      PrettyLogger.warning(
        'Google Sign-In may not be available',
        data: {'error': e.toString()},
        tag: 'AuthRemoteDataSource',
      );
      return false;
    }
  }

  @override
  Future<bool> isFacebookSignInAvailable() async {
    // Don't check availability by accessing the plugin
    // This causes MissingPluginException if plugin isn't registered
    // Instead, we'll let the login attempt handle the error gracefully
    // This method always returns true, and errors will be caught in signInWithFacebook
    PrettyLogger.debug(
      'Facebook Sign-In availability check skipped (will be checked during login)',
      tag: 'AuthRemoteDataSource',
    );
    return true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    PrettyLogger.info(
      'Sending password reset email',
      data: {'email': email},
      tag: 'AuthRemoteDataSource',
    );

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      PrettyLogger.success(
        'Password reset email sent successfully',
        data: {'email': email},
        tag: 'AuthRemoteDataSource',
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Failed to send password reset email',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message, 'email': email},
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure(e.message ?? 'Failed to send password reset email');
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Unexpected error sending password reset email',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('Failed to send password reset email');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    PrettyLogger.info('Updating password', tag: 'AuthRemoteDataSource');

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure('No user is currently signed in');
      }

      await user.updatePassword(newPassword);

      PrettyLogger.success(
        'Password updated successfully',
        tag: 'AuthRemoteDataSource',
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Failed to update password',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message},
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure(e.message ?? 'Failed to update password');
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Unexpected error updating password',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('Failed to update password');
    }
  }

  @override
  Future<void> reauthenticateWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    PrettyLogger.info('Reauthenticating user', tag: 'AuthRemoteDataSource');

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure('No user is currently signed in');
      }

      await user.reauthenticateWithCredential(credential);

      PrettyLogger.success(
        'User reauthenticated successfully',
        tag: 'AuthRemoteDataSource',
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      PrettyLogger.error(
        'Failed to reauthenticate user',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'message': e.message},
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure(e.message ?? 'Failed to reauthenticate user');
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Unexpected error reauthenticating user',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      throw AuthFailure('Failed to reauthenticate user');
    }
  }
}
