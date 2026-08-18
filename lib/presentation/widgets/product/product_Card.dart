import 'package:flutter/material.dart';

import '../../../Domain/entities/product_entity.dart';


class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // أيقونة المنتج
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getTypeColor(product.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(product.type),
                    color: _getTypeColor(product.type),
                    size: 30,
                  ),
                ),

                // if (product.username != null && product.username!.isNotEmpty)
                  Text(
                    ' ${product.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

              ],
            ),
            
            const SizedBox(width: 16),
            
            // معلومات المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(product.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.type,
                      style: TextStyle(
                        color: _getTypeColor(product.type),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} ريال',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            // زر الحذف
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'إلكترونيات':
        return Icons.devices;
      case 'ملابس':
        return Icons.checkroom;
      case 'طعام':
        return Icons.restaurant;
      case 'أثاث':
        return Icons.chair;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'إلكترونيات':
        return Colors.blue;
      case 'ملابس':
        return Colors.purple;
      case 'طعام':
        return Colors.orange;
      case 'أثاث':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}