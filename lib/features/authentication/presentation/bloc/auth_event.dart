part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogle extends AuthEvent {
  const SignInWithGoogle();
}

class SignUpWithGoogle extends AuthEvent {
  const SignUpWithGoogle();
}

class SignInWithFacebook extends AuthEvent {
  const SignInWithFacebook();
}

class SignUpWithFacebook extends AuthEvent {
  const SignUpWithFacebook();
}

class SignOut extends AuthEvent {
  const SignOut();
}

