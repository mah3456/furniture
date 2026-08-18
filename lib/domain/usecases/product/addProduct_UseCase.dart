import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repostitories/product_Repository.dart';

class AddProductUseCase implements UseCase<Product, AddProductParams> {
  final ProductRepository repository;

  AddProductUseCase({required this.repository});

  @override
  Future<Either<Failure, Product>> call(AddProductParams params) async {
    return await repository.addProduct(params.product);
  }
}

class AddProductParams {
  final Product product;
  AddProductParams(this.product);
}