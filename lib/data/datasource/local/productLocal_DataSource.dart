import 'package:sqflite/sqflite.dart';
import 'package:stores/Domain/entities/product_entity.dart';
import '../../models/product_Model.dart';
import 'authLocal_DataSource.dart';

abstract class ProductLocalDataSource {
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct({required Product product});

  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getUserProducts({required String userId});
  Future<int> deleteProduct({required String id});

  Future<List<ProductModel>> getProductsWithUsers({required String userId});

}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final _authDataSource = AuthLocalDataSourceImpl() ;

  static const String tableName = 'products';


  // Get database from AuthLocalDataSource (shared instance)
  Future<Database> get _database async {
    return await _authDataSource.getDatabase();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    print('إضافة منتج جديد: ${product.name}');
    final db = await _database;

    try {
      final id = await db.insert(tableName, {
        'user_id': int.parse(product.Userid!), // تحويل userId إلى int
        'name': product.name,
        'type': product.type,
        'description': product.description,
        'price': product.price,
      });

      print('تم إضافة المنتج برقم ID: $id');

      return ProductModel(
        id: id.toString(),
        Userid: product.Userid,
        name: product.name,
        type: product.type,
        description: product.description,
        price: product.price,
      );
    } catch (e) {
      print('❌ فشل إضافة المنتج: $e');
      rethrow;
    }
  }




  @override
  Future<ProductModel> updateProduct({required Product product}) async {
    print('🔄 تحديث المنتج رقم: ${product.id}');
    final db = await _database;

    try {
      // التحقق من وجود المنتج
      final existing = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [int.parse(product.id!)],
      );

      if (existing.isEmpty) {
        throw Exception('المنتج غير موجود');
      }

      // تحديث البيانات
      final result = await db.update(
        tableName,
        {
          'user_id': int.parse(product.Userid!),
          'name': product.name,
          'type': product.type,
          'description': product.description,
          'price': product.price,
        },
        where: 'id = ?',
        whereArgs: [int.parse(product.id!)],
      );

      if (result == 0) {
        throw Exception('فشل تحديث المنتج');
      }

      print('✅ تم تحديث المنتج رقم: ${product.id} بنجاح');

      // إرجاع المنتج المحدث
      return ProductModel(
        id: product.id,
        Userid: product.Userid,
        name: product.name,
        type: product.type,
        description: product.description,
        price: product.price,
      );
    } catch (e) {
      print('❌ فشل تحديث المنتج: $e');
      rethrow;
    }
  }



  @override
  Future<List<ProductModel>> getProducts() async {
    print('📋 جلب جميع المنتجات مع بيانات المستخدمين');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
      SELECT 
        p.*,
        u.name as user_name,
        u.email as user_email,
        u.phone as user_phone
      FROM $tableName p
      LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON p.user_id = u.id
      ORDER BY p.id DESC
    ''');

      print('✅ عدد المنتجات: ${result.length}');

      return result.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب المنتجات مع بيانات المستخدمين: $e');
      return [];
    }
  }




  @override
  Future<List<ProductModel>> getUserProducts({required String userId}) async {
    print('جلب منتجات المستخدم: $userId');
    final db = await _database;

    try {
      final result = await db.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: [int.parse(userId)], // تحويل إلى int
        orderBy: 'id DESC',
      );

      print('عدد المنتجات للمستخدم $userId: ${result.length}');

      return result.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب منتجات المستخدم: $e');
      return [];
    }
  }

  @override
  Future<int> deleteProduct({required String id}) async {
    print('حذف المنتج رقم: $id');
    final db = await _database;

    try {
      var res = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [int.parse(id)],
      );

      return res;
    } catch (e) {

      rethrow;
    }
  }


  @override
  Future<List<ProductModel>> getProductsWithUsers({required String userId}) async {
    print('📋 جلب منتجات المستخدم $userId مع بياناته');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          u.name as user_name,
          u.email as user_email,
          u.phone as user_phone
        FROM $tableName p
        LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON p.user_id = u.id
        WHERE p.user_id = ?
        ORDER BY p.id DESC
      ''', [int.parse(userId)]);

      print('✅ تم جلب ${result.length} منتج للمستخدم $userId');

      return result.map((json) {
        return ProductModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ فشل جلب المنتجات مع المستخدمين: $e');
      return [];
    }
  }


  // Future<List<ProductModel>> getCurrentUserProductsWithUserData() async {
  //   print('📋 جلب منتجات المستخدم الحالي مع بياناته');
  //
  //   // الحصول على المستخدم الحالي
  //   final currentUser = await _authDataSource.getCachedUser();
  //   if (currentUser == null) {
  //     print('❌ لا يوجد مستخدم مسجل دخول');
  //     return [];
  //   }
  //
  //   return await getProductsWithUsers(userId: currentUser.id.toString());
  // }

  // دالة لحساب عدد المنتجات لمستخدم معين
  Future<int> getUserProductsCount(String userId) async {
    print('حساب عدد منتجات المستخدم: $userId');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $tableName 
        WHERE user_id = ?
      ''', [int.parse(userId)]);

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      print('❌ فشل حساب عدد المنتجات: $e');
      return 0;
    }
  }

  // دالة لحذف جميع منتجات مستخدم
  Future<void> deleteUserProducts(String userId) async {
    print('حذف جميع منتجات المستخدم: $userId');
    final db = await _database;

    try {
      await db.delete(
        tableName,
        where: 'user_id = ?',
        whereArgs: [int.parse(userId)],
      );
      print('تم حذف جميع منتجات المستخدم بنجاح');
    } catch (e) {
      print('❌ فشل حذف منتجات المستخدم: $e');
      rethrow;
    }
  }
}