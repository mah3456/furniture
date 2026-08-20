import 'package:dartz/dartz.dart';
import '../../Domain/repostitories/product_Repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../Domain/entities/product_entity.dart';
import '../datasource/local/productLocal_DataSource.dart';
import '../models/product_Model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      // تحويل Product (Entity) إلى ProductModel
      final productModel = ProductModel.fromEntity(product);
      final result = await localDataSource.addProduct(productModel);
      return Right(result); // ProductModel extends Product
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }



  @override
  Future<Either<Failure, Product>> updateProduct({required Product product}) async {
    try {
      print('🔄 تحديث المنتج في الـ Repository');
      final products = await localDataSource.updateProduct(product: product);


      return Right(products);
    }  on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }


  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await localDataSource.getProducts();
      // ProductModel extends Product، لذلك يمكننا إرجاعها مباشرة
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteProduct({required String id}) async {
    try {
      var res = await localDataSource.deleteProduct(id:id);
      return  Right(res);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getUserProducts({required String userId}) async {
    try {
      final products = await localDataSource.getUserProducts(userId: userId);
      // ProductModel extends Product، لذلك يمكننا إرجاعها مباشرة
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }



  @override
  Future<Either<Failure, List<Product>>> getProductsWithUsersImpl({required String userId}) async {
    try {
      final products = await localDataSource.getProductsWithUsers(userId: userId);
      // ProductModel extends Product، لذلك يمكننا إرجاعها مباشرة
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }



}