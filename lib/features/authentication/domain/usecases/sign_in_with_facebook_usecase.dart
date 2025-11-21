import 'package:dartz/dartz.dart';
import 'package:easacc_task/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithFacebookUseCase {
  final AuthRepository repository;

  SignInWithFacebookUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    try {
      final user = await repository.signInWithFacebook();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}

