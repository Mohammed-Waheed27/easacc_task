import 'package:equatable/equatable.dart';
import 'user_credentials.dart';

class UserEntity extends Equatable {
  final String id;
  final UserCredentials credentials;
  final String? name;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.credentials,
    this.name,
    this.photoUrl,
    this.createdAt,
    this.lastLoginAt,
  });

  String get email => credentials.email;
  String get authProvider => credentials.authProvider;

  UserEntity copyWith({
    String? id,
    UserCredentials? credentials,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      credentials: credentials ?? this.credentials,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        credentials,
        name,
        photoUrl,
        createdAt,
        lastLoginAt,
      ];
}
