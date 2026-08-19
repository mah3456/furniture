
import '../../Domain/entities/commen_tEntity.dart';


class CommentModel extends CommentEntity {


  CommentModel({
    String? id,
    required String productId,
    required String userId,
    required String content,
    required String Username,
    required int rating,
    required String createdAt,
    required String updatedAt,
  }): super(
    id: id,
    productId: productId,
    userName: Username,
    userId: userId,
    content: content,
    rating: rating,
    createdAt: createdAt ,
    updatedAt: updatedAt

  );



  // إنشاء من JSON (من قاعدة البيانات)
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      content: json['content'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: json['created_at'].toString() ,
      updatedAt: json['updated_at'].toString() ,
      Username: json['user_name'],
    );
  }

  // تحويل إلى JSON للتخزين في قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': int.parse(productId),
      'user_id': int.parse(userId),
      'content': content,
      'user_name': userName,
      'rating': rating,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // إنشاء كائن جديد للإضافة (بدون id)
  Map<String, dynamic> toInsertJson() {
    return {
      'product_id': int.parse(productId),
      'user_id': int.parse(userId),
      'content': content,
      'rating': rating,
      'user_name': userName,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // نسخ الكائن مع تغيير بعض الحقول
  @override
  CommentModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? content,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
  }) {
    return CommentModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      Username: userName ?? this.userName,
      rating: rating ?? this.rating,
      createdAt: createdAt.toString() ?? this.createdAt,
      updatedAt: updatedAt.toString() ?? this.updatedAt,
    );
  }

  // تحويل إلى Entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      productId: productId,
      userId: userId,
      content: content,
      userName: userName,
      rating: rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // إنشاء Model من Entity
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      content: entity.content,
      Username: entity.userName,
      rating: entity.rating,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // الحصول على كائن المستخدم المرتبط
  // UserModel? getUser() {
  //   if (userName != null && userEmail != null) {
  //     return UserModel(
  //       id: int.parse(userId),
  //       name: userName!,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //   }
  //   return null;
  // }
  //
  // // الحصول على كائن المنتج المرتبط
  // ProductModel? getProduct() {
  //   if (productName != null) {
  //     return ProductModel(
  //       id: productId,
  //       Userid: userId,
  //       name: productName!,
  //       type: productType ?? '',
  //       description: productDescription ?? '',
  //       price: productPrice ?? 0.0,
  //     );
  //   }
  //   return null;
  // }

  // التحقق من صحة التقييم
  bool isValidRating() {
    return rating >= 1 && rating <= 5;
  }

  // الحصول على نص التقييم
  String getRatingText() {
    switch (rating) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return 'غير معروف';
    }
  }

  // الحصول على نجمة التقييم
  String getRatingStars() {
    return '★' * rating + '☆' * (5 - rating);
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, productId: $productId, userId: $userId, '
        'content: $content, rating: $rating, userName: $userName)';
  }
}