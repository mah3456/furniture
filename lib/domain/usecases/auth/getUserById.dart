import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import 'package:stores/Domain/repostitories/auth_repository.dart';
import 'package:stores/Domain/entities/user_entity.dart';


class GetUserById implements UseCase<UserEntity, UserParams> {
  final AuthRepository repository;

  GetUserById({required this.repository});



  @override
  Future<Either<Failure, UserEntity>> call(UserParams params) async {
    return await repository.getUserById(id: params.id);
  }

}

class UserParams {
  final int id;
  UserParams(this.id);
}