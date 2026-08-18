import 'package:dartz/dartz.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import 'package:stores/data/models/user_model.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import 'package:stores/Domain/repostitories/auth_repository.dart';


class UpdateUserUseCase implements UseCase<int, UpdateParams> {
  final AuthRepository repository;

  UpdateUserUseCase({required this.repository});



  @override
  Future<Either<Failure, int>> call(UpdateParams params) async {
    print('RegisterUseCase: بدء عملية التسجيل');
    return await repository.updateUser(user: params.user);
  }

}

class UpdateParams {
  final UserEntity user;

  UpdateParams(this.user);
}