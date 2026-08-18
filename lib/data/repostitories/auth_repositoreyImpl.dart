

import 'package:dartz/dartz.dart';
import '../../Domain/entities/user_entity.dart';
import '../../Domain/repostitories/auth_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasource/local/authLocal_DataSource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});



  @override
  Future<Either<Failure, UserEntity>> register(UserEntity user) async {
    try {
      // تحويل UserEntity إلى UserModel (بما أن UserModel extends UserEntity فهذا آمن)
      final userModel = UserModel.fromEntity(user);

      // استدعاء الـ DataSource الذي يرجع UserModel
      final registeredUser = await localDataSource.register(userModel);

      // UserModel هو UserEntity، لذلك يمكننا إرجاعه مباشرة
      return Right(registeredUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }


  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password
  }) async {
    try {
      final user = await localDataSource.login(email, password);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }




  @override
  Future<Either<Failure, int>> updateUser({required UserEntity user}) async {
    try {

      final result = await localDataSource.updateUser(user: user);
      return Right(result); // result يجب أن يكون من نوع int
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }




  @override
  Future<Either<Failure, UserEntity>> getUserById({required int id}) async {
    try {

      final result = await localDataSource.getUserById(id: id);
      return Right(result!); // result يجب أن يكون من نوع int
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }







  @override
  Future<UserEntity?> getCachedUser() async {
   return localDataSource.getCachedUser();
  }



  @override
  Future<bool> isLoggedIn() async {
   return await localDataSource.isLoggedIn();
  }




  @override
  Future<bool> logout() async {
    await localDataSource.logout();
    return true; // أو حسب منطقك
  }


}