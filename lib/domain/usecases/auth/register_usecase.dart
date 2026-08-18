import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import 'package:stores/Domain/repostitories/auth_repository.dart';
import 'package:stores/Domain/entities/user_entity.dart';


class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});



  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    print('RegisterUseCase: بدء عملية التسجيل');
    return await repository.register(params.user);
  }

}

class RegisterParams {
  final UserEntity user;
  RegisterParams(this.user);
}