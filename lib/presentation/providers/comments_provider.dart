
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../Domain/entities/commen_tEntity.dart';
import '../../Domain/repostitories/comment_Repository.dart';
import '../../core/errors/failures.dart';
import '../../data/datasource/local/Commen_tLocalDataSource.dart';
import '../../data/repostitories/comment_RepositoryImpl.dart';
import '../../Domain/usecases/product/add_CommentUseCase.dart';
import '../../Domain/usecases/comments/get_ProductCommentsUseCase.dart';

final commentLocalDataSourceProvider = Provider<CommentLocalDataSource>((ref) {
  return CommentLocalDataSourceImpl();
});

// ==================== Repository Provider ====================
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final localDataSource = ref.watch(commentLocalDataSourceProvider);
  return CommentRepositoryImpl(localDataSource: localDataSource);
  // أو استخدام النسخة مع الكاش
  // return CommentRepositoryWithCacheImpl(localDataSource: localDataSource);
});

// ==================== UseCase Providers ====================
final addCommentUseCaseProvider = Provider<AddCommentUsecase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return AddCommentUsecase(repository: repository);
});


// final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return GetCommentsUseCase(repository: repository);
// });
//

final getProductCommentsUseCaseProvider = Provider<GetProductCommentsUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return GetProductCommentsUseCase(repository: repository);
});
//
// final getUserCommentsUseCaseProvider = Provider<GetUserCommentsUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return GetUserCommentsUseCase(repository: repository);
// });
//
// final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return DeleteCommentUseCase(repository: repository);
// });
//
// final updateCommentUseCaseProvider = Provider<UpdateCommentUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return UpdateCommentUseCase(repository: repository);
// });
//
// final getProductAverageRatingUseCaseProvider = Provider<GetProductAverageRatingUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return GetProductAverageRatingUseCase(repository: repository);
// });
//
// final getProductCommentsCountUseCaseProvider = Provider<GetProductCommentsCountUseCase>((ref) {
//   final repository = ref.watch(commentRepositoryProvider);
//   return GetProductCommentsCountUseCase(repository: repository);
// });

// ==================== Comment State ====================
class CommentState {
  final bool isLoading;
  final List<CommentEntity> comments;
  final String? error;
  final double averageRating;
  final int commentsCount;

  CommentState({
    this.isLoading = false,
    this.comments = const [],
    this.error,
    this.averageRating = 0.0,
    this.commentsCount = 0,
  });

  CommentState copyWith({
    bool? isLoading,
    List<CommentEntity>? comments,
    String? error,
    double? averageRating,
    int? commentsCount,
  }) {
    return CommentState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      error: error,
      averageRating: averageRating ?? this.averageRating,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  // حساب متوسط التقييمات
  double calculateAverageRating() {
    if (comments.isEmpty) return 0.0;
    final sum = comments.fold(0, (sum, comment) => sum + comment.rating);
    return sum / comments.length;
  }

  // حساب عدد التعليقات
  int calculateCommentsCount() {
    return comments.length;
  }

  // الحصول على توزيع التقييمات
  Map<int, int> getRatingDistribution() {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = comments.where((c) => c.rating == i).length;
    }
    return distribution;
  }

  // الحصول على نسبة كل تقييم
  Map<int, double> getRatingPercentage() {
    if (comments.isEmpty) return {};
    final distribution = getRatingDistribution();
    return distribution.map((key, value) =>
        MapEntry(key, (value / comments.length) * 100)
    );
  }
}

// ==================== Comment Notifier ====================
class CommentNotifier extends StateNotifier<CommentState> {
  final AddCommentUsecase addCommentUseCase;
  // final GetCommentsUseCase getCommentsUseCase;
  final GetProductCommentsUseCase getProductCommentsUseCase;
  // final GetUserCommentsUseCase getUserCommentsUseCase;
  // final DeleteCommentUseCase deleteCommentUseCase;
  // final UpdateCommentUseCase updateCommentUseCase;
  // final GetProductAverageRatingUseCase getProductAverageRatingUseCase;
  // final GetProductCommentsCountUseCase getProductCommentsCountUseCase;

  // تخزين productId الحالي لتحديث الإحصائيات
  String? _currentProductId;

  CommentNotifier({
    required this.addCommentUseCase,
    // required this.getCommentsUseCase,
    required this.getProductCommentsUseCase,
    // required this.getUserCommentsUseCase,
    // required this.deleteCommentUseCase,
    // required this.updateCommentUseCase,
    // required this.getProductAverageRatingUseCase,
    // required this.getProductCommentsCountUseCase,
  }) : super(CommentState());

  // ==================== جلب جميع التعليقات ====================
  // Future<void> loadComments() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await getCommentsUseCase(NoParams());
  //
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: _mapFailureToMessage(failure),
  //       );
  //     },
  //         (comments) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         comments: comments,
  //         commentsCount: comments.length,
  //         averageRating: state.calculateAverageRating(),
  //       );
  //     },
  //   );
  // }
  //
  // // ==================== جلب تعليقات منتج معين ====================
  Future<void> loadProductComments({required String productId}) async {
    _currentProductId = productId;
    state = state.copyWith(isLoading: true, error: null);

    final result = await getProductCommentsUseCase(ProductCommentsParams(productId: productId));

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
          (comments) {
        state = state.copyWith(
          isLoading: false,
          comments: comments,
          commentsCount: comments.length,
          averageRating: state.calculateAverageRating(),
        );

        // تحديث الإحصائيات من الـ UseCases
        // _loadProductStatistics(productId);
      },
    );
  }
  //
  // // ==================== جلب تعليقات مستخدم معين ====================
  // Future<void> loadUserComments({required String userId}) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await getUserCommentsUseCase(UserCommentsParams(userId: userId));
  //
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: _mapFailureToMessage(failure),
  //       );
  //     },
  //         (comments) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         comments: comments,
  //         commentsCount: comments.length,
  //         averageRating: state.calculateAverageRating(),
  //       );
  //     },
  //   );
  // }
  //
  // // ==================== جلب إحصائيات المنتج ====================
  // Future<void> _loadProductStatistics(String productId) async {
  //   // جلب متوسط التقييمات
  //   final avgResult = await getProductAverageRatingUseCase(ProductIdParams(productId: productId));
  //   avgResult.fold(
  //         (failure) => null,
  //         (avgRating) {
  //       state = state.copyWith(averageRating: avgRating);
  //     },
  //   );
  //
  //   // جلب عدد التعليقات
  //   final countResult = await getProductCommentsCountUseCase(ProductIdParams(productId: productId));
  //   countResult.fold(
  //         (failure) => null,
  //         (count) {
  //       state = state.copyWith(commentsCount: count);
  //     },
  //   );
  // }

  // ==================== إضافة تعليق ====================
  Future<bool> addComment({
    required String productId,
    required String userId,
    required String content,
    required int rating,
    required String userName
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final comment = CommentEntity(
      productId: productId,
      userId: userId,
      content: content,
      rating: rating,
      userName: userName,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );

    final result = await addCommentUseCase(AddCommentParams(comment));

    bool isSuccess = false;
    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
          (newComment) {
        // إضافة التعليق الجديد إلى القائمة
        final updatedComments = [newComment, ...state.comments];
        state = state.copyWith(
          isLoading: false,
          comments: updatedComments,
          commentsCount: updatedComments.length,
          averageRating: state.calculateAverageRating(),
          error: null,
        );
        isSuccess = true;

        // تحديث إحصائيات المنتج إذا كان هناك productId محدد
        // if (_currentProductId != null) {
        //   _loadProductStatistics(_currentProductId!);
        // }
      },
    );

    return isSuccess;
  }



  // ==================== حذف تعليق ====================
  // Future<bool> deleteComment({required String id}) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await deleteCommentUseCase(DeleteCommentParams(id: id));
  //
  //   bool isSuccess = false;
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: _mapFailureToMessage(failure),
  //       );
  //     },
  //         (deletedCount) {
  //       // إزالة التعليق المحذوف من القائمة
  //       final updatedComments = state.comments.where((c) => c.id != id).toList();
  //       state = state.copyWith(
  //         isLoading: false,
  //         comments: updatedComments,
  //         commentsCount: updatedComments.length,
  //         averageRating: state.calculateAverageRating(),
  //         error: null,
  //       );
  //       isSuccess = true;
  //
  //       // تحديث إحصائيات المنتج إذا كان هناك productId محدد
  //       if (_currentProductId != null) {
  //         _loadProductStatistics(_currentProductId!);
  //       }
  //     },
  //   );
  //
  //   return isSuccess;
  // }
  //
  // // ==================== تحديث تعليق ====================
  // Future<bool> updateComment({
  //   required String id,
  //   required String content,
  //   required int rating,
  // }) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   // البحث عن التعليق الحالي
  //   final existingComment = state.comments.firstWhere(
  //         (c) => c.id == id,
  //     orElse: () => throw Exception('التعليق غير موجود'),
  //   );
  //
  //   final updatedComment = CommentEntity(
  //     id: id,
  //     productId: existingComment.productId,
  //     userId: existingComment.userId,
  //     content: content,
  //     rating: rating,
  //     createdAt: existingComment.createdAt,
  //     updatedAt: DateTime.now(),
  //   );
  //
  //   final result = await updateCommentUseCase(UpdateCommentParams(updatedComment));
  //
  //   bool isSuccess = false;
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: _mapFailureToMessage(failure),
  //       );
  //     },
  //         (updatedCount) {
  //       // تحديث التعليق في القائمة
  //       final updatedComments = state.comments.map((c) {
  //         if (c.id == id) {
  //           return updatedComment;
  //         }
  //         return c;
  //       }).toList();
  //
  //       state = state.copyWith(
  //         isLoading: false,
  //         comments: updatedComments,
  //         averageRating: state.calculateAverageRating(),
  //         error: null,
  //       );
  //       isSuccess = true;
  //
  //       // تحديث إحصائيات المنتج إذا كان هناك productId محدد
  //       if (_currentProductId != null) {
  //         _loadProductStatistics(_currentProductId!);
  //       }
  //     },
  //   );
  //
  //   return isSuccess;
  // }

  // ==================== تحديث إحصائيات المنتج يدوياً ====================
  // Future<void> refreshProductStatistics(String productId) async {
  //   await _loadProductStatistics(productId);
  // }

  // ==================== مسح التعليقات ====================
  void clearComments() {
    state = CommentState();
    _currentProductId = null;
  }

  // ==================== مسح الخطأ ====================
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ==================== تحويل الخطأ إلى رسالة ====================
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'خطأ في الخادم: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'خطأ في التخزين المؤقت';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
}

// ==================== Comment Provider ====================
final commentProvider = StateNotifierProvider<CommentNotifier, CommentState>((ref) {
  final addCommentUseCase = ref.watch(addCommentUseCaseProvider);
  // final getCommentsUseCase = ref.watch(getCommentsUseCaseProvider);
  final getProductCommentsUseCase = ref.watch(getProductCommentsUseCaseProvider);
  // final getUserCommentsUseCase = ref.watch(getUserCommentsUseCaseProvider);
  // final deleteCommentUseCase = ref.watch(deleteCommentUseCaseProvider);
  // final updateCommentUseCase = ref.watch(updateCommentUseCaseProvider);
  // final getProductAverageRatingUseCase = ref.watch(getProductAverageRatingUseCaseProvider);
  // final getProductCommentsCountUseCase = ref.watch(getProductCommentsCountUseCaseProvider);

  return CommentNotifier(
    addCommentUseCase: addCommentUseCase,
    // getCommentsUseCase: getCommentsUseCase,
    getProductCommentsUseCase: getProductCommentsUseCase,
    // getUserCommentsUseCase: getUserCommentsUseCase,
    // deleteCommentUseCase: deleteCommentUseCase,
    // updateCommentUseCase: updateCommentUseCase,
    // getProductAverageRatingUseCase: getProductAverageRatingUseCase,
    // getProductCommentsCountUseCase: getProductCommentsCountUseCase,
  );
});

// ==================== Comment Providers المساعدة ====================

// Provider للحصول على التعليقات فقط
final commentsListProvider = Provider<List<CommentEntity>>((ref) {
  final state = ref.watch(commentProvider);
  return state.comments;
});

// Provider للحصول على حالة التحميل
final commentsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(commentProvider);
  return state.isLoading;
});

// Provider للحصول على متوسط التقييمات
final commentsAverageRatingProvider = Provider<double>((ref) {
  final state = ref.watch(commentProvider);
  return state.averageRating;
});

// Provider للحصول على عدد التعليقات
final commentsCountProvider = Provider<int>((ref) {
  final state = ref.watch(commentProvider);
  return state.commentsCount;
});

// Provider للحصول على توزيع التقييمات
final commentsRatingDistributionProvider = Provider<Map<int, int>>((ref) {
  final state = ref.watch(commentProvider);
  return state.getRatingDistribution();
});

// Provider للحصول على نسبة التقييمات
final commentsRatingPercentageProvider = Provider<Map<int, double>>((ref) {
  final state = ref.watch(commentProvider);
  return state.getRatingPercentage();
});

// Provider للحصول على أحدث 5 تعليقات
final recentCommentsProvider = Provider<List<CommentEntity>>((ref) {
  final state = ref.watch(commentProvider);
  return state.comments.take(5).toList();
});

// Provider للحصول على خطأ
final commentsErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(commentProvider);
  return state.error;
});