import 'package:dartz/dartz.dart';
import 'package:easacc_task/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    try {
      final user = await repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}

