// lib/domain/entities/comment_entity.dart

import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? id;
  final String productId;
  final String userId;
  final String content;
  final int rating;
  final String userName;
  final String createdAt;
  final String updatedAt;

  CommentEntity({
    this.id,
    required this.userName,
    required this.productId,
    required this.userId,
    required this.content,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  // نسخ الكائن مع تغيير بعض الحقول
  CommentEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    String? content,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      userName: userName,
      rating: rating ?? this.rating,
      createdAt: createdAt.toString() ?? this.createdAt,
      updatedAt: updatedAt.toString() ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CommentEntity(id: $id, productId: $productId, userId: $userId, content: $content, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentEntity &&
        other.id == id &&
        other.productId == productId &&
        other.userId == userId &&
        other.content == content &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        rating.hashCode;
  }

  @override
  // TODO: implement props
  List<Object?> get props =>  [id , productId , userName , userId , content , rating , createdAt , updatedAt];
}