import 'package:dartz/dartz.dart';
import '../../Domain/entities/commen_tEntity.dart';
import '../../Domain/repostitories/comment_Repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasource/local/Commen_tLocalDataSource.dart';
import '../models/comment_Model.dart';



class CommentRepositoryImpl implements CommentRepository {
  final CommentLocalDataSource localDataSource;

  // التخزين المؤقت
  List<CommentEntity>? _cachedComments;
  Map<String, List<CommentEntity>> _cachedProductComments = {};
  Map<String, List<CommentEntity>> _cachedUserComments = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheDuration = Duration(minutes: 5);

  CommentRepositoryImpl({required this.localDataSource});

  // التحقق من صلاحية الكاش
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;
  }

  // مسح الكاش
  void _clearCache() {
    _cachedComments = null;
    _cachedProductComments.clear();
    _cachedUserComments.clear();
    _lastCacheUpdate = null;
  }

  // تحديث وقت الكاش
  void _updateCacheTime() {
    _lastCacheUpdate = DateTime.now();
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({required CommentEntity comment}) async {
    try {
      print('🏪 إضافة تعليق في المستودع مع الكاش');

      // تحويل Comment (Entity) إلى CommentModel
      final commentModel = CommentModel.fromEntity(comment);
      final result = await localDataSource.addComment(comment: commentModel);

      _clearCache();

      print('✅ تم إضافة التعليق بنجاح');
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }




// @override
// Future<Either<Failure, List<CommentEntity>>> getComments() async {
//   try {
//     print('🏪 جلب جميع التعليقات من المستودع مع الكاش');
//
//     // التحقق من الكاش
//     if (_cachedComments != null && _isCacheValid()) {
//       print('✅ استخدام الكاش: ${_cachedComments!.length} تعليق');
//       return Right(_cachedComments!);
//     }
//
//     final comments = await localDataSource.getComments();
//     _cachedComments = comments; // CommentModel extends CommentEntity
//     _updateCacheTime();
//
//     print('✅ تم جلب ${comments.length} تعليق من المصدر');
//     return Right(_cachedComments!);
//   } on CacheException catch (e) {
//     // إرجاع الكاش حتى لو منتهي الصلاحية في حالة خطأ الكاش
//     if (_cachedComments != null) {
//       print('⚠️ استخدام الكاش المنتهي في حالة الخطأ');
//       return Right(_cachedComments!);
//     }
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     // إرجاع الكاش حتى لو منتهي الصلاحية في حالة خطأ
//     if (_cachedComments != null) {
//       print('⚠️ استخدام الكاش المنتهي في حالة الخطأ');
//       return Right(_cachedComments!);
//     }
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

@override
Future<Either<Failure, List<CommentEntity>>> getProductComments({required String productId}) async {
  try {
    print('🏪 جلب تعليقات المنتج $productId من المستودع مع الكاش');

    // التحقق من الكاش
    if (_cachedProductComments.containsKey(productId) && _isCacheValid()) {
      print('✅ استخدام الكاش للمنتج $productId: ${_cachedProductComments[productId]!.length} تعليق');
      return Right(_cachedProductComments[productId]!);
    }

    final comments = await localDataSource.getProductComments(productId: productId);
    _cachedProductComments[productId] = comments; // CommentModel extends CommentEntity
    _updateCacheTime();

    print('✅ تم جلب ${comments.length} تعليق للمنتج $productId');
    return Right(_cachedProductComments[productId]!);
  } on CacheException catch (e) {
    if (_cachedProductComments.containsKey(productId)) {
      print('⚠️ استخدام الكاش المنتهي للمنتج $productId');
      return Right(_cachedProductComments[productId]!);
    }
    return Left(CacheFailure(e.message));
  } catch (e) {
    if (_cachedProductComments.containsKey(productId)) {
      print('⚠️ استخدام الكاش المنتهي للمنتج $productId');
      return Right(_cachedProductComments[productId]!);
    }
    return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
  }
}




// @override
// Future<Either<Failure, List<CommentEntity>>> getUserComments({required String userId}) async {
//   try {
//     print('🏪 جلب تعليقات المستخدم $userId من المستودع مع الكاش');
//
//     // التحقق من الكاش
//     if (_cachedUserComments.containsKey(userId) && _isCacheValid()) {
//       print('✅ استخدام الكاش للمستخدم $userId: ${_cachedUserComments[userId]!.length} تعليق');
//       return Right(_cachedUserComments[userId]!);
//     }
//
//     final comments = await localDataSource.getUserComments(userId: userId);
//     _cachedUserComments[userId] = comments; // CommentModel extends CommentEntity
//     _updateCacheTime();
//
//     print('✅ تم جلب ${comments.length} تعليق للمستخدم $userId');
//     return Right(_cachedUserComments[userId]!);
//   } on CacheException catch (e) {
//     if (_cachedUserComments.containsKey(userId)) {
//       print('⚠️ استخدام الكاش المنتهي للمستخدم $userId');
//       return Right(_cachedUserComments[userId]!);
//     }
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     if (_cachedUserComments.containsKey(userId)) {
//       print('⚠️ استخدام الكاش المنتهي للمستخدم $userId');
//       return Right(_cachedUserComments[userId]!);
//     }
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }




// @override
// Future<Either<Failure, List<CommentEntity>>> getCommentsWithUsersAndProducts({
//   required String productId,
// }) async {
//   try {
//     print('🏪 جلب تعليقات المنتج $productId مع العلاقات من المستودع');
//
//     final comments = await localDataSource.getCommentsWithUsersAndProducts(
//       productId: productId,
//     );
//
//     print('✅ تم جلب ${comments.length} تعليق مع العلاقات');
//     return Right(comments); // CommentModel extends CommentEntity
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }



// @override
// Future<Either<Failure, int>> deleteComment({required String id}) async {
//   try {
//     print('🏪 حذف التعليق $id من المستودع');
//
//     final result = await localDataSource.deleteComment(id: id);
//
//     // مسح الكاش بعد الحذف
//     _clearCache();
//
//     print('✅ تم حذف التعليق بنجاح');
//     return Right(result);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }



// @override
// Future<Either<Failure, int>> updateComment(CommentEntity comment) async {
//   try {
//     print('🏪 تحديث التعليق ${comment.id} في المستودع');
//
//     // تحويل Comment (Entity) إلى CommentModel
//     final commentModel = CommentModel.fromEntity(comment);
//     final result = await localDataSource.updateComment(commentModel);
//
//     // مسح الكاش بعد التحديث
//     _clearCache();
//
//     print('✅ تم تحديث التعليق بنجاح');
//     return Right(result);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }
//



// @override
// Future<Either<Failure, double>> getProductAverageRating(String productId) async {
//   try {
//     print('🏪 حساب متوسط تقييمات المنتج $productId من المستودع');
//
//     final avgRating = await localDataSource.getProductAverageRating(productId);
//
//     print('✅ متوسط التقييمات: $avgRating');
//     return Right(avgRating);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

// @override
// Future<Either<Failure, int>> getProductCommentsCount(String productId) async {
//   try {
//     print('🏪 حساب عدد تعليقات المنتج $productId من المستودع');
//
//     final count = await localDataSource.getProductCommentsCount(productId);
//
//     print('✅ عدد التعليقات: $count');
//     return Right(count);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

// @override
// Future<Either<Failure, void>> deleteProductComments(String productId) async {
//   try {
//     print('🏪 حذف جميع تعليقات المنتج $productId من المستودع');
//
//     await localDataSource.deleteProductComments(productId);
//
//     // مسح الكاش بعد الحذف
//     _clearCache();
//
//     print('✅ تم حذف جميع تعليقات المنتج بنجاح');
//     return const Right(null);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

// @override
// Future<Either<Failure, void>> deleteUserComments(String userId) async {
//   try {
//     print('🏪 حذف جميع تعليقات المستخدم $userId من المستودع');
//
//     await localDataSource.deleteUserComments(userId);
//
//     // مسح الكاش بعد الحذف
//     _clearCache();
//
//     print('✅ تم حذف جميع تعليقات المستخدم بنجاح');
//     return const Right(null);
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

// @override
// Future<Either<Failure, List<CommentEntity>>> getRecentComments({int limit = 10}) async {
//   try {
//     print('🏪 جلب أحدث $limit تعليق من المستودع');
//
//     final comments = await localDataSource.getRecentComments(limit: limit);
//
//     print('✅ تم جلب ${comments.length} تعليق حديث');
//     return Right(comments); // CommentModel extends CommentEntity
//   } on CacheException catch (e) {
//     return Left(CacheFailure(e.message));
//   } catch (e) {
//     return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
//   }
// }

// دالة لتحديث الكاش يدوياً
// Future<void> refreshCache() async {
//   print('🔄 تحديث الكاش يدوياً');
//   _clearCache();
//   await getComments();
//   print('✅ تم تحديث الكاش بنجاح');
// }

}