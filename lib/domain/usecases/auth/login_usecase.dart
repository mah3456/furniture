import 'package:dartz/dartz.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repostitories/auth_repository.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(email:  params.email,password:  params.password);
  }
}



class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}


