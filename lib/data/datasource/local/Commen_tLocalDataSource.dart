import 'package:sqflite/sqflite.dart';
import 'package:stores/Domain/entities/commen_tEntity.dart';
import 'package:stores/data/datasource/local/productLocal_DataSource.dart';
import '../../models/comment_Model.dart';
import 'authLocal_DataSource.dart';

abstract class CommentLocalDataSource {
  Future<CommentModel> addComment({required CommentModel comment});
  Future<List<CommentModel>> getComments();
  Future<List<CommentModel>> getProductComments({required String productId});
  Future<List<CommentModel>> getUserComments({required String userId});
  Future<int> deleteComment({required String id});
  Future<int> updateComment(CommentModel comment);
  Future<List<CommentModel>> getCommentsWithUsersAndProducts({required String productId});
}

class CommentLocalDataSourceImpl implements CommentLocalDataSource {


  final _authDataSource = AuthLocalDataSourceImpl();
  
  static const String tableName = 'comments';

  // Get database from AuthLocalDataSource (shared instance)
  Future<Database> get _database async {
    return await _authDataSource.getDatabase();
  }

  @override
  Future<CommentModel> addComment({required CommentEntity comment}) async {
    print('📝 إضافة تعليق جديد للمنتج: ${comment.productId}');
    final db = await _database;

    try {
      final id = await db.insert(tableName, {
        'product_id': int.parse(comment.productId!),
        'user_id': int.parse(comment.userId!),
        'content': comment.content,
        'rating': comment.rating,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ تم إضافة التعليق برقم ID: $id');

      return CommentModel(
        id: id.toString(),
        productId: comment.productId,
        userId: comment.userId,
        content: comment.content,
        Username: comment.userName,
        rating: comment.rating,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );
    } catch (e) {
      print('❌ فشل إضافة التعليق: $e');
      rethrow;
    }
  }

  @override
  Future<List<CommentModel>> getComments() async {
    print('📋 جلب جميع التعليقات مع بيانات المستخدمين والمنتجات');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name as user_name,
          u.email as user_email,
          u.phone as user_phone,
          p.name as product_name,
          p.price as product_price,
          p.type as product_type
        FROM $tableName c
        LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON c.user_id = u.id
        LEFT JOIN ${ProductLocalDataSourceImpl.tableName} p ON c.product_id = p.id
        ORDER BY c.created_at DESC
      ''');

      print('✅ عدد التعليقات: ${result.length}');

      return result.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب التعليقات مع بيانات المستخدمين والمنتجات: $e');
      return [];
    }
  }

  @override
  Future<List<CommentModel>> getProductComments({required String productId}) async {
    print('📋 جلب تعليقات المنتج: $productId');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name as user_name,
          u.email as user_email,
          u.phone as user_phone
        FROM $tableName c
        LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON c.user_id = u.id
        WHERE c.product_id = ?
        ORDER BY c.created_at DESC
      ''', [int.parse(productId)]);

      print('✅ عدد تعليقات المنتج $productId: ${result.length}');

      return result.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب تعليقات المنتج: $e');
      return [];
    }
  }

  @override
  Future<List<CommentModel>> getUserComments({required String userId}) async {
    print('📋 جلب تعليقات المستخدم: $userId');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          p.name as product_name,
          p.price as product_price,
          p.type as product_type
        FROM $tableName c
        LEFT JOIN ${ProductLocalDataSourceImpl.tableName} p ON c.product_id = p.id
        WHERE c.user_id = ?
        ORDER BY c.created_at DESC
      ''', [int.parse(userId)]);

      print('✅ عدد تعليقات المستخدم $userId: ${result.length}');

      return result.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب تعليقات المستخدم: $e');
      return [];
    }
  }

  @override
  Future<List<CommentModel>> getCommentsWithUsersAndProducts({required String productId}) async {
    print('📋 جلب تعليقات المنتج $productId مع بيانات المستخدمين والمنتجات');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name as user_name,
          u.email as user_email,
          u.phone as user_phone,
          p.name as product_name,
          p.price as product_price,
          p.type as product_type,
          p.description as product_description
        FROM $tableName c
        LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON c.user_id = u.id
        LEFT JOIN ${ProductLocalDataSourceImpl.tableName} p ON c.product_id = p.id
        WHERE c.product_id = ?
        ORDER BY c.created_at DESC
      ''', [int.parse(productId)]);

      print('✅ تم جلب ${result.length} تعليق للمنتج $productId');

      return result.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب التعليقات مع المستخدمين والمنتجات: $e');
      return [];
    }
  }

  @override
  Future<int> deleteComment({required String id}) async {
    print('🗑️ حذف التعليق رقم: $id');
    final db = await _database;

    try {
      var res = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [int.parse(id)],
      );
      
      print('✅ تم حذف التعليق بنجاح');
      return res;
    } catch (e) {
      print('❌ فشل حذف التعليق: $e');
      rethrow;
    }
  }

  @override
  Future<int> updateComment(CommentModel comment) async {
    print('✏️ تحديث التعليق رقم: ${comment.id}');
    final db = await _database;

    try {
      var res = await db.update(
        tableName,
        {
          'content': comment.content,
          'rating': comment.rating,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [int.parse(comment.id!)],
      );
      
      print('✅ تم تحديث التعليق بنجاح');
      return res;
    } catch (e) {
      print('❌ فشل تحديث التعليق: $e');
      rethrow;
    }
  }

  // دالة لحساب متوسط التقييمات لمنتج معين
  Future<double> getProductAverageRating(String productId) async {
    print('📊 حساب متوسط تقييمات المنتج: $productId');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT AVG(rating) as avg_rating 
        FROM $tableName 
        WHERE product_id = ?
      ''', [int.parse(productId)]);

      double avgRating = 0.0;
      if (result.isNotEmpty && result.first['avg_rating'] != null) {
        avgRating = (result.first['avg_rating'] as double?) ?? 0.0;
      }
      
      print('✅ متوسط التقييمات: $avgRating');
      return avgRating;
    } catch (e) {
      print('❌ فشل حساب متوسط التقييمات: $e');
      return 0.0;
    }
  }

  // دالة لحساب عدد التعليقات لمنتج معين
  Future<int> getProductCommentsCount(String productId) async {
    print('📊 حساب عدد تعليقات المنتج: $productId');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $tableName 
        WHERE product_id = ?
      ''', [int.parse(productId)]);

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      print('❌ فشل حساب عدد التعليقات: $e');
      return 0;
    }
  }

  // دالة لحذف جميع تعليقات منتج معين
  Future<void> deleteProductComments(String productId) async {
    print('🗑️ حذف جميع تعليقات المنتج: $productId');
    final db = await _database;

    try {
      await db.delete(
        tableName,
        where: 'product_id = ?',
        whereArgs: [int.parse(productId)],
      );
      print('✅ تم حذف جميع تعليقات المنتج بنجاح');
    } catch (e) {
      print('❌ فشل حذف تعليقات المنتج: $e');
      rethrow;
    }
  }

  // دالة لحذف جميع تعليقات مستخدم معين
  Future<void> deleteUserComments(String userId) async {
    print('🗑️ حذف جميع تعليقات المستخدم: $userId');
    final db = await _database;

    try {
      await db.delete(
        tableName,
        where: 'user_id = ?',
        whereArgs: [int.parse(userId)],
      );
      print('✅ تم حذف جميع تعليقات المستخدم بنجاح');
    } catch (e) {
      print('❌ فشل حذف تعليقات المستخدم: $e');
      rethrow;
    }
  }

  // دالة للحصول على أحدث التعليقات
  Future<List<CommentModel>> getRecentComments({int limit = 10}) async {
    print('📋 جلب أحدث $limit تعليق');
    final db = await _database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name as user_name,
          u.email as user_email,
          p.name as product_name
        FROM $tableName c
        LEFT JOIN ${AuthLocalDataSourceImpl.userTable} u ON c.user_id = u.id
        LEFT JOIN ${ProductLocalDataSourceImpl.tableName} p ON c.product_id = p.id
        ORDER BY c.created_at DESC
        LIMIT ?
      ''', [limit]);

      print('✅ تم جلب ${result.length} تعليق حديث');

      return result.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ فشل جلب أحدث التعليقات: $e');
      return [];
    }
  }
}