import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, Product>> addProduct(Product product);
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, List<Product>>> getUserProducts({required String userId});
  Future<Either<Failure, List<Product>>> getProductsWithUsersImpl({required String userId});
  Future<Either<Failure, int>> deleteProduct({required String id});
}