import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product/product_Card.dart';
import '../products/product_DetailsScreen.dart';




// ✅ الصفحة الرئيسية - عرض المنتجات
class MyProducts extends ConsumerWidget {
  const MyProducts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final productNotifier = ref.read(productProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('منتجاتي'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر تحديث المنتجات
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {

              final uid = await shared.getString('user_id');


              ref.read(productProvider.notifier).loadUserProducts(userId: uid!);

              print(productState.products);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          
          // ملخص سريع
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                _buildStatItem(
                  Icons.inventory_2,
                  '${productState.products.length}',
                  'منتج',
                ),
                _buildStatItem(
                  Icons.attach_money,
                  _calculateTotalPrice(productState.products),
                  'الإجمالي',
                ),
                _buildStatItem(
                  Icons.category,
                  '${_getUniqueTypes(productState.products)}',
                  'نوع',
                ),
              ],
            ),
          ),

          // قائمة المنتجات
          Expanded(
            child: productState.isLoading ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل المنتجات...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ) : productState.error != null ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد اي منتجات'!,
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(productProvider.notifier)
                          .loadUserProducts(userId: '1');
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : productState.products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات بعد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر + لإضافة منتج جديد',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(productProvider.notifier)
                    .loadProducts();
              },
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 20,),
                padding: const EdgeInsets.only(
                  bottom: 80,
                  left: 23,
                  right: 23,
                ),
                itemCount: productState.products.length,
                itemBuilder: (context, index) {
                  final product = productState.products[index];
                  return ProductCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    product: product,
                    onDelete: () {
                      _showDeleteDialog(
                        context: context, ref: ref, product: product ,notifier: productNotifier
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عنصر إحصائية
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // حساب السعر الإجمالي
  String _calculateTotalPrice(List products) {
    double total = 0;
    for (var product in products) {
      total += product.price;
    }
    return '${total.toStringAsFixed(0)} ر.س';
  }

  // عدد الأنواع المختلفة
  int _getUniqueTypes(List products) {
    final types = products.map((p) => p.type).toSet();
    return types.length;
  }

  // مربع حوار حذف المنتج
  void _showDeleteDialog({required BuildContext context,
    required WidgetRef ref,
    required dynamic product,
    required ProductNotifier notifier

  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // إعادة تحميل المنتجات بعد الحذف

              final uid = await shared.getString('user_id');


              ref.read(productProvider.notifier).loadUserProducts(userId: uid!);

              notifier.deleteProduct(id: product.id);



              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف ${product.name}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

