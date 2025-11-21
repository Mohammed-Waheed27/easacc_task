import '../../domain/entities/user_entity.dart';
import 'user_credentials_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.credentials,
    super.name,
    super.photoUrl,
    super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromFirebaseUser({
    required String id,
    required String email,
    String? password,
    String? name,
    String? photoUrl,
    required String authProvider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id,
      credentials: UserCredentialsModel(
        email: email,
        password: password,
        authProvider: authProvider,
      ),
      name: name,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      credentials: UserCredentialsModel.fromJson(
        json['credentials'] as Map<String, dynamic>,
      ),
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credentials': (credentials as UserCredentialsModel).toJson(),
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      credentials: credentials,
      name: name,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
