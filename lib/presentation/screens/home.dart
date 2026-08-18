import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stores/presentation/screens/user/my_products.dart';
import 'package:stores/presentation/screens/products/add_ProductScreen.dart';
import 'package:stores/presentation/screens/user/notifications.dart';
import 'package:stores/presentation/screens/user/profile.dart';
import '../../main.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_Card.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    ref.read(productProvider.notifier).loadProducts();

    _pages = [
      const HomePage(),
      const MyProducts(),
      const NotificationsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      // زر الإضافة العائم - يظهر فقط في الصفحة الرئيسية
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          ).then((_) {
            // إعادة تحميل المنتجات عند العودة
            ref.read(productProvider.notifier).loadProducts();
          });
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) async {

              final uid = await shared.getString('user_id');


              if(index == 0 ){
                ref.read(productProvider.notifier).loadProducts();
              } else if(index ==1){
                ref.read(productProvider.notifier).loadUserProducts(userId: uid!);
              }

              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag_rounded, size: 30),
                label: 'المنتجات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.production_quantity_limits),
                activeIcon: Icon(Icons.production_quantity_limits, size: 30),
                label: 'منتجاتي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                activeIcon: Icon(Icons.notifications_rounded, size: 30),
                label: 'الإشعارات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded, size: 30),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ الصفحة الرئيسية - عرض المنتجات
class HomePage extends ConsumerWidget {
  const HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextButton(
          child: Text('test' , style: TextStyle(color: Colors.white),),

          onPressed: () async{

            final uid = await shared.getString('user_id');

            print(uid);


          },
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر تحديث المنتجات
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(productProvider.notifier).loadProducts();
            },
          ),
        ],
      ),
      body:  Column(
        children: [
     

          // قائمة المنتجات
          Expanded(
            child: productState.isLoading
                ? const Center(
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
            )
                : productState.error != null
                ? Center(
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
                          .loadProducts();

                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 80,
                  left: 8,
                  right: 8,
                ),
                itemCount: productState.products.length,
                itemBuilder: (context, index) {
                  final product = productState.products[index];
                  return ProductCard(
                    product: product,
                    onDelete: () {
                      _showDeleteDialog(
                          context, ref, product);
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



  Widget _buildStatItem({required IconData icon,required String value,required String label}) {
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





  // مربع حوار حذف المنتج
  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, dynamic product) {
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
            onPressed: () {
              Navigator.pop(context);
              // إعادة تحميل المنتجات بعد الحذف
              ref.read(productProvider.notifier).loadProducts();
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


