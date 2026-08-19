// lib/presentation/widgets/comment_item_widget.dart

import 'package:flutter/material.dart';
import 'package:stores/presentation/widgets/product/rating_Widget.dart';
import '../../../Domain/entities/commen_tEntity.dart';

class CommentItemWidget extends StatelessWidget {
  final CommentEntity comment;
  final Function(String) onDelete;
  final bool showDelete;

  const CommentItemWidget({
    Key? key,
    required this.comment,
    required this.onDelete,
    this.showDelete = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المستخدم
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            radius: 24,
            child: Text(
              comment.userId.isNotEmpty ? comment.userId[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // محتوى التعليق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المستخدم
                Text(
                  'مستخدم ${comment.userId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                
                // التقييم
                RatingWidget(
                  rating: comment.rating,
                  size: 16,
                ),
                const SizedBox(height: 8),
                
                // نص التعليق
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                // تاريخ التعليق
                Text(
                  // DateFormat('yyyy/MM/dd - HH:mm').format(comment.createdAt),
                  comment.createdAt,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          // زر الحذف
          if (showDelete)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () => _showDeleteDialog(context),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التعليق'),
        content: const Text('هل أنت متأكد من حذف هذا التعليق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(comment.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}