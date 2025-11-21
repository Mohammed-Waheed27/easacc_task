import 'package:equatable/equatable.dart';

class UserCredentials extends Equatable {
  final String email;
  final String? password; // Optional, only for email/password auth
  final String authProvider; // 'email', 'google', 'facebook'

  const UserCredentials({
    required this.email,
    this.password,
    required this.authProvider,
  });

  UserCredentials copyWith({
    String? email,
    String? password,
    String? authProvider,
  }) {
    return UserCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  @override
  List<Object?> get props => [email, password, authProvider];
}

