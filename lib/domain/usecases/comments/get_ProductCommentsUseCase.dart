
import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/commen_tEntity.dart';
import '../../repostitories/comment_Repository.dart';

class GetProductCommentsUseCase implements UseCase<List<CommentEntity>, ProductCommentsParams> {
  final CommentRepository repository;

  GetProductCommentsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CommentEntity>>> call(ProductCommentsParams params) async {
    return await repository.getProductComments(productId: params.productId);
  }
}

class ProductCommentsParams {
  final String productId;

  ProductCommentsParams({required this.productId});
}