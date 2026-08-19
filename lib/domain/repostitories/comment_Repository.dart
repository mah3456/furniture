


import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/commen_tEntity.dart';

abstract class CommentRepository {

  Future<Either<Failure, CommentEntity>> addComment({required CommentEntity comment});

  // جلب جميع التعليقات
  // Future<List<CommentEntity>> getComments();
  //
  // // جلب تعليقات منتج معين
  Future<Either<Failure, List<CommentEntity>>> getProductComments({required String productId});


  //
  // // جلب تعليقات مستخدم معين
  // Future<List<CommentEntity>> getUserComments({required String userId});
  //
  // // جلب تعليقات منتج معين مع بيانات المستخدمين والمنتجات
  // Future<List<CommentEntity>> getCommentsWithUsersAndProducts({required String productId});
  //
  // // حذف تعليق
  // Future<int> deleteComment({required String id});
  //
  // // تحديث تعليق
  // Future<int> updateComment(CommentEntity comment);
  //
  // // حساب متوسط التقييمات لمنتج
  // Future<double> getProductAverageRating(String productId);
  //
  // // حساب عدد التعليقات لمنتج
  // Future<int> getProductCommentsCount(String productId);
  //
  // // حذف جميع تعليقات منتج
  // Future<void> deleteProductComments(String productId);
  //
  // // حذف جميع تعليقات مستخدم
  // Future<void> deleteUserComments(String userId);
  //
  // // جلب أحدث التعليقات
  // Future<List<CommentEntity>> getRecentComments({int limit = 10});
}