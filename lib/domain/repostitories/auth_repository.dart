import 'package:dartz/dartz.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register(UserEntity user);
  Future<Either<Failure, UserEntity>> login({required String email,required String password});
  Future<Either<Failure, int>>  updateUser({required UserEntity user});
  Future<bool> isLoggedIn();
  Future<bool> logout();

  Future<Either<Failure, UserEntity>> getUserById({required int id});
  Future<UserEntity?> getCachedUser();

}