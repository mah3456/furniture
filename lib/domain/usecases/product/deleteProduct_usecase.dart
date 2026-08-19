import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repostitories/product_Repository.dart';

class DeleteProductUsecase implements UseCase<int, DeleteParams> {
  final ProductRepository repository;

  DeleteProductUsecase({required this.repository});

  @override
  Future<Either<Failure, int>> call(DeleteParams params) async {
    return await repository.deleteProduct(id: params.id);
  }



}

class DeleteParams {
  final String id;
  DeleteParams(this.id);
}