import 'package:easacc_task/core/di/injection_container.dart';
import 'package:easacc_task/core/errors/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository = getIt<AuthRepository>();

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPassword>(_onSignUpWithEmailAndPassword);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignUpWithGoogle>(_onSignUpWithGoogle);
    on<SignInWithFacebook>(_onSignInWithFacebook);
    on<SignUpWithFacebook>(_onSignUpWithFacebook);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithGoogle(
    SignUpWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithFacebook(
    SignInWithFacebook event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithFacebook();
      emit(AuthAuthenticated(user));
    } on AuthFailure catch (e) {
      // Extract user-friendly message from AuthFailure
      String errorMessage = e.message;

      // Handle specific Facebook errors
      if (e.message.contains('cancelled') ||
          e.message.contains('was cancelled')) {
        // Check if user might be already logged in
        // This can happen if user logged in but cancelled Google Play redirect
        try {
          final currentUser = await authRepository.getCurrentUser();
          if (currentUser != null) {
            emit(AuthAuthenticated(currentUser));
            return;
          }
        } catch (_) {
          // Ignore errors when checking current user
        }
        errorMessage =
            'Facebook sign in was cancelled. If you already logged in, please try again or check your profile.';
      } else if (e.message.contains('Invalid OAuth') ||
          e.message.contains('signature')) {
        errorMessage =
            'Facebook authentication failed. Please add the correct Key Hash in Facebook Console.\n\nSee FACEBOOK_KEY_HASH_FINAL_FIX.md for instructions.';
      } else if (e.message.contains('not available') ||
          e.message.contains('rebuild')) {
        errorMessage =
            'Facebook sign in is not available. Please restart the app completely (stop and run again, not hot reload) or use email/Google sign in.';
      }

      emit(AuthError(errorMessage));
    } catch (e) {
      // Handle other exceptions (like MissingPluginException)
      String errorMessage = e.toString();

      if (errorMessage.contains('Invalid OAuth') ||
          errorMessage.contains('signature')) {
        errorMessage =
            'Facebook authentication failed. Please add the correct Key Hash in Facebook Console.\n\nSee FACEBOOK_KEY_HASH_FINAL_FIX.md for instructions.';
      } else if (errorMessage.contains('MissingPluginException') ||
          errorMessage.contains('No implementation found')) {
        errorMessage =
            'Facebook sign in is not available. Please stop the app completely and run it again (not hot reload).';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignUpWithFacebook(
    SignUpWithFacebook event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithFacebook();
      emit(AuthAuthenticated(user));
    } on AuthFailure catch (e) {
      // Extract user-friendly message from AuthFailure
      String errorMessage = e.message;

      // Handle specific Facebook errors
      if (e.message.contains('cancelled') ||
          e.message.contains('was cancelled')) {
        // Check if user might be already logged in
        try {
          final currentUser = await authRepository.getCurrentUser();
          if (currentUser != null) {
            emit(AuthAuthenticated(currentUser));
            return;
          }
        } catch (_) {
          // Ignore errors when checking current user
        }
        errorMessage =
            'Facebook sign up was cancelled. If you already logged in, please try again or check your profile.';
      } else if (e.message.contains('Invalid OAuth') ||
          e.message.contains('signature')) {
        errorMessage =
            'Facebook authentication failed. Please add the correct Key Hash in Facebook Console.\n\nSee FACEBOOK_KEY_HASH_FINAL_FIX.md for instructions.';
      } else if (e.message.contains('not available') ||
          e.message.contains('rebuild')) {
        errorMessage =
            'Facebook sign up is not available. Please restart the app completely (stop and run again, not hot reload) or use email/Google sign up.';
      }

      emit(AuthError(errorMessage));
    } catch (e) {
      // Handle other exceptions (like MissingPluginException)
      String errorMessage = e.toString();

      if (errorMessage.contains('Invalid OAuth') ||
          errorMessage.contains('signature')) {
        errorMessage =
            'Facebook authentication failed. Please add the correct Key Hash in Facebook Console.\n\nSee FACEBOOK_KEY_HASH_FINAL_FIX.md for instructions.';
      } else if (errorMessage.contains('MissingPluginException') ||
          errorMessage.contains('No implementation found')) {
        errorMessage =
            'Facebook sign up is not available. Please stop the app completely and run it again (not hot reload).';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
