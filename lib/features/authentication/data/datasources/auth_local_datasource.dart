import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> saveCredentials(String email, String? password, String authProvider);
  Future<Map<String, String?>?> getSavedCredentials();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl({required this.storageService});

  @override
  Future<void> cacheUser(UserModel user) async {
    await StorageService.setString(
      AppConstants.keyUserEmail,
      user.email,
    );
    await StorageService.setString(
      AppConstants.keyAuthProvider,
      user.authProvider,
    );
    await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final isLoggedIn = StorageService.getBool(AppConstants.keyIsLoggedIn);
    if (isLoggedIn != true) return null;

    final email = StorageService.getString(AppConstants.keyUserEmail);
    final authProvider = StorageService.getString(AppConstants.keyAuthProvider);

    if (email == null || authProvider == null) return null;

    // Return a basic user model with cached data
    return UserModel.fromFirebaseUser(
      id: 'cached_user',
      email: email,
      authProvider: authProvider,
    );
  }

  @override
  Future<void> clearCache() async {
    await StorageService.remove(AppConstants.keyUserEmail);
    await StorageService.remove(AppConstants.keyAuthProvider);
    await StorageService.setBool(AppConstants.keyIsLoggedIn, false);
  }

  @override
  Future<void> saveCredentials(
    String email,
    String? password,
    String authProvider,
  ) async {
    await StorageService.setString('${AppConstants.keyUserEmail}_cred', email);
    await StorageService.setString(
      '${AppConstants.keyAuthProvider}_cred',
      authProvider,
    );
    // Note: In production, password should be encrypted before storing
    if (password != null) {
      await StorageService.setString(
        '${AppConstants.keyUserEmail}_password',
        password,
      );
    }
  }

  @override
  Future<Map<String, String?>?> getSavedCredentials() async {
    final email = StorageService.getString('${AppConstants.keyUserEmail}_cred');
    final password =
        StorageService.getString('${AppConstants.keyUserEmail}_password');
    final authProvider =
        StorageService.getString('${AppConstants.keyAuthProvider}_cred');

    if (email == null) return null;

    return {
      'email': email,
      'password': password,
      'authProvider': authProvider,
    };
  }
}

