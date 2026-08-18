import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repostitories/product_Repository.dart';

class GetUserProductsUseCase implements UseCase<List<Product>, UserParams> {
  final ProductRepository repository;

  GetUserProductsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Product>>> call(UserParams params) async {
    return await repository.getProductsWithUsersImpl(userId: params.id);
  }
}


class UserParams {
  final String id;


  UserParams( this.id);
}