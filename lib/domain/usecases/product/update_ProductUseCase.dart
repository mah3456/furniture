import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/models/product_Model.dart';
import '../../entities/product_entity.dart';
import '../../repostitories/product_Repository.dart' show ProductRepository;



class UpdateProductUseCase implements UseCase<Product, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProductUseCase({required this.repository});

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) async {
    return await repository.updateProduct(product: params.product);
  }


}

class UpdateProductParams {
  final Product product;

  UpdateProductParams({required this.product});
}