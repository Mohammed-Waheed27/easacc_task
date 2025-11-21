import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_credentials.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/pretty_logger.dart';

class UserCredentialsModel extends UserCredentials {
  const UserCredentialsModel({
    required super.email,
    super.password,
    required super.authProvider,
  });

  /// Create from Firebase User
  factory UserCredentialsModel.fromFirebaseUser(
    firebase_auth.User user, {
    String? password,
  }) {
    final providerId = user.providerData.isNotEmpty
        ? user.providerData[0].providerId
        : 'email';

    // Map Firebase provider IDs to our auth provider format
    String authProvider;
    switch (providerId) {
      case 'google.com':
        authProvider = 'google';
        break;
      case 'facebook.com':
        authProvider = 'facebook';
        break;
      case 'password':
      default:
        authProvider = 'email';
    }

    final credentials = UserCredentialsModel(
      email: user.email ?? '',
      password: password,
      authProvider: authProvider,
    );

    PrettyLogger.debug(
      'UserCredentialsModel created from Firebase User',
      data: {
        'email': credentials.email,
        'authProvider': credentials.authProvider,
        'hasPassword': password != null,
      },
      tag: 'UserCredentialsModel',
    );

    return credentials;
  }

  /// Create from JSON
  factory UserCredentialsModel.fromJson(Map<String, dynamic> json) {
    try {
      final credentials = UserCredentialsModel(
        email: json['email'] as String,
        password: json['password'] as String?,
        authProvider: json['authProvider'] as String? ?? 'email',
      );

      PrettyLogger.debug(
        'UserCredentialsModel created from JSON',
        data: credentials.toJson(),
        tag: 'UserCredentialsModel',
      );

      return credentials;
    } catch (e, stackTrace) {
      PrettyLogger.error(
        'Failed to create UserCredentialsModel from JSON',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserCredentialsModel',
      );
      rethrow;
    }
  }

  /// Convert to JSON (password excluded for security)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'authProvider': authProvider,
      // Never store password in JSON for security
    };
  }

  /// Convert to JSON with password (use with caution, only for local storage)
  Map<String, dynamic> toJsonWithPassword() {
    return {'email': email, 'password': password, 'authProvider': authProvider};
  }

  /// Convert to domain entity
  UserCredentials toEntity() {
    return UserCredentials(
      email: email,
      password: password,
      authProvider: authProvider,
    );
  }

  /// Create from domain entity
  factory UserCredentialsModel.fromEntity(UserCredentials entity) {
    return UserCredentialsModel(
      email: entity.email,
      password: entity.password,
      authProvider: entity.authProvider,
    );
  }

  /// Validate email format
  /// For social logins, email can be empty (user might not have provided it)
  bool isValidEmail() {
    // For social logins, email is optional
    if (isSocialLogin() && email.isEmpty) {
      PrettyLogger.debug(
        'Email is empty for social login (this is acceptable)',
        data: {'email': email, 'authProvider': authProvider},
        tag: 'UserCredentialsModel',
      );
      return true;
    }

    final isValid = Validators.validateEmail(email) == null;
    if (!isValid) {
      PrettyLogger.warning(
        'Invalid email format',
        data: {'email': email},
        tag: 'UserCredentialsModel',
      );
    }
    return isValid;
  }

  /// Validate password (if present)
  bool isValidPassword() {
    if (password == null || password!.isEmpty) {
      PrettyLogger.warning(
        'Password is null or empty',
        tag: 'UserCredentialsModel',
      );
      return false;
    }

    // Minimum password length validation
    if (password!.length < 6) {
      PrettyLogger.warning(
        'Password too short (minimum 6 characters)',
        tag: 'UserCredentialsModel',
      );
      return false;
    }

    return true;
  }

  /// Validate credentials based on auth provider
  bool isValid() {
    if (!isValidEmail()) {
      return false;
    }

    // For email/password auth, password is required
    if (authProvider == 'email' && !isValidPassword()) {
      return false;
    }

    // For social auth, password is not required
    if ((authProvider == 'google' || authProvider == 'facebook') &&
        password != null) {
      PrettyLogger.warning(
        'Password should not be set for social auth',
        tag: 'UserCredentialsModel',
      );
    }

    PrettyLogger.success(
      'UserCredentials validated successfully',
      data: {'email': email, 'authProvider': authProvider},
      tag: 'UserCredentialsModel',
    );

    return true;
  }

  /// Check if credentials are for social login
  bool isSocialLogin() {
    return authProvider == 'google' || authProvider == 'facebook';
  }

  /// Check if credentials are for email/password login
  bool isEmailPasswordLogin() {
    return authProvider == 'email';
  }

  /// Create a copy with updated values
  UserCredentialsModel copyWith({
    String? email,
    String? password,
    String? authProvider,
  }) {
    return UserCredentialsModel(
      email: email ?? this.email,
      password: password ?? this.password,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  /// Create empty credentials
  factory UserCredentialsModel.empty() {
    return const UserCredentialsModel(
      email: '',
      password: null,
      authProvider: 'email',
    );
  }

  @override
  String toString() {
    return 'UserCredentialsModel(email: $email, authProvider: $authProvider, hasPassword: ${password != null})';
  }
}
