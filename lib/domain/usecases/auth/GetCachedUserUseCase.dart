
import 'package:dartz/dartz.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import 'package:stores/Domain/repostitories/auth_repository.dart';

import '../../../core/errors/failures.dart';

class GetCachedUserUseCase {
  final AuthRepository repository;

  GetCachedUserUseCase({required this.repository});

  Future<UserEntity?> call() async {
    return await repository.getCachedUser();
  }



}