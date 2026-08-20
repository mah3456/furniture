import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/commen_tEntity.dart';
import '../../repostitories/comment_Repository.dart';

class AddCommentUsecase implements UseCase<CommentEntity, AddCommentParams> {
  final CommentRepository repository;

  AddCommentUsecase({required this.repository});

  @override
  Future<Either<Failure, CommentEntity>> call(AddCommentParams params) async {
    return await repository.addComment(comment: params.product);
  }



}

class AddCommentParams {
  final CommentEntity product;
  AddCommentParams(this.product);


}