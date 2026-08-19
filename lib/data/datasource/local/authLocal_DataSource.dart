import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> register(UserModel user);
  Future<UserModel> login(String email, String password);
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<void> saveUserToCache(UserModel user);
  Future<UserEntity?> getCachedUser();
  Future<int> updateUser({required UserEntity user});
  Future<void> deleteUser(int userId);
  Future<List<UserModel>> getAllUsers();
  Future<bool> isEmailExists(String email);
  Future<UserEntity?> getUserById({required int id});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  Database? _database;
  static const String userTable = 'users';
  static const String productTable = 'products';
  static const String commentTable ='comments';

  // مفاتيح SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }


  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }


  Future<Database> initDatabase() async {
    print('📁 تهيئة قاعدة البيانات...');

    String path = join(await getDatabasesPath(), 'store_data.db');
    print('📂 مسار قاعدة البيانات: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('🚀 بدء إنشاء جداول قاعدة البيانات (الإصدار $version)...');

    try {
      // 1. إنشاء جدول المستخدمين
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $userTable(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT NOT NULL,
          password TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('✅ تم إنشاء جدول $userTable بنجاح');

      // 2. إنشاء جدول المنتجات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $productTable(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES $userTable(id) ON DELETE CASCADE
        )
      ''');
      print('✅ تم إنشاء جدول $productTable بنجاح');



      await db.execute('''
          CREATE TABLE $commentTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            rating INTEGER CHECK(rating >= 1 AND rating <= 5),
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (product_id) REFERENCES $productTable(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES $userTable(id) ON DELETE CASCADE
          )
        ''');

      print('🎉 تم إنشاء جميع الجداول بنجاح');
    } catch (e) {
      print('❌ خطأ في إنشاء الجداول: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 ترقية قاعدة البيانات من $oldVersion إلى $newVersion');

    // if (oldVersion < 2) {
    //   print('📦 إضافة جدول $productTable...');
    //
    //   try {
    //     await db.execute('''
    //       CREATE TABLE IF NOT EXISTS $productTable(
    //         id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         user_id INTEGER NOT NULL,
    //         name TEXT NOT NULL,
    //         type TEXT NOT NULL,
    //         price REAL NOT NULL,
    //         description TEXT,
    //         quantity INTEGER DEFAULT 0,
    //         created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    //         FOREIGN KEY (user_id) REFERENCES $userTable(id) ON DELETE CASCADE
    //       )
    //     ''');
    //     print('✅ تم إنشاء جدول $productTable في الترقية');
    //   } catch (e) {
    //     print('❌ فشل إنشاء $productTable بـ FOREIGN KEY: $e');
    //
    //     // محاولة بديلة بدون FOREIGN KEY
    //     try {
    //       await db.execute('''
    //         CREATE TABLE IF NOT EXISTS $productTable(
    //           id INTEGER PRIMARY KEY AUTOINCREMENT,
    //           user_id INTEGER NOT NULL,
    //           name TEXT NOT NULL,
    //           type TEXT NOT NULL,
    //           price REAL NOT NULL,
    //           description TEXT,
    //           quantity INTEGER DEFAULT 0,
    //           created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    //         )
    //       ''');
    //       print('✅ تم إنشاء $productTable بدون FOREIGN KEY');
    //     } catch (e2) {
    //       print('❌ فشل إنشاء $productTable تماماً: $e2');
    //     }
    //   }
    // }
  }

  // ==============================================
  // ✅ دوال إدارة المستخدمين
  // ==============================================

  @override
  Future<UserModel> register(UserModel user) async {
    print('📝 بدء عملية التسجيل للمستخدم: ${user.email}');
    final db = await database;

    try {
      // التحقق من عدم وجود البريد الإلكتروني مسبقاً
      // final existingUser = await db.query(
      //   userTable,
      //   where: 'email = ?',
      //   whereArgs: [user.email],
      // );
      //
      // if (existingUser.isNotEmpty) {
      //   print('❌ البريد الإلكتروني موجود مسبقاً');
      //   throw CacheException('البريد الإلكتروني مستخدم بالفعل');
      // }

      // إضافة المستخدم
      final id = await db.insert(userTable, {
        'name': user.name,
        'phone': user.phone,
        'email': user.email,
        'password': user.password,
      });

      print('✅ تم تسجيل المستخدم برقم ID: $id');

      final newUser = UserModel(
        id: id,
        name: user.name,
        phone: user.phone,
        email: user.email,
      );

      // حفظ في SharedPreferences
      await saveUserToCache(newUser);

      return newUser;
    } catch (e) {
      print('❌ فشل التسجيل: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    print('🔐 محاولة تسجيل الدخول: $email');
    final db = await database;

    try {
      final result = await db.query(
        userTable,
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      print('📊 نتائج البحث: ${result.length}');

      if (result.isEmpty) {
        throw CacheException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

      final userData = result.first;
      print('👤 بيانات المستخدم: $userData');

      final user = UserModel(
        id: userData['id'] as int,
        name: userData['name'] as String? ?? '',
        phone: userData['phone'] as String? ?? '',
        email: userData['email'] as String? ?? '',
      );

      // حفظ بيانات المستخدم في SharedPreferences
      await saveUserToCache(user);

      return user;
    } catch (e) {
      print('❌ فشل تسجيل الدخول: $e');
      rethrow;
    }
  }



  @override
  Future<int> updateUser({required UserEntity user}) async {
    print('✏️ تحديث بيانات المستخدم: $userث.email}');
    final db = await database;

    try {
      final result = await db.update(
        userTable,
        {
          'name':  user.name,
          'phone': user.phone,
          'email': user.email,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (result == 0) {
        throw CacheException('المستخدم غير موجود');
      }

      print('✅ تم تحديث بيانات المستخدم بنجاح');


      // تحديث البيانات في SharedPreferences
      await saveUserToCache(user);

      return result;
    } catch (e) {
      print('❌ فشل تحديث المستخدم: $e');
      rethrow;
    }
  }


  @override
  Future<void> deleteUser(int userId) async {
    print('🗑️ حذف المستخدم رقم: $userId');
    final db = await database;

    try {
      // حذف المنتجات المرتبطة أولاً (إذا لم يكن هناك ON DELETE CASCADE)
      await db.delete(
        productTable,
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // حذف المستخدم
      final result = await db.delete(
        userTable,
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result == 0) {
        throw CacheException('المستخدم غير موجود');
      }

      print('✅ تم حذف المستخدم بنجاح');
    } catch (e) {
      print('❌ فشل حذف المستخدم: $e');
      rethrow;
    }
  }




  @override
  Future<UserEntity?> getUserById({required int id}) async {
    try {

      final db = await database;


      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب المستخدم من قاعدة البيانات: $e');
      return null;
    }
  }



  @override
  Future<List<UserModel>> getAllUsers() async {
    print('📋 استرجاع جميع المستخدمين');
    final db = await database;

    try {
      final result = await db.query(
        userTable,
        orderBy: 'id DESC',
      );

      print('✅ تم استرجاع ${result.length} مستخدم');

      return result.map((data) => UserModel(
        id: data['id'] as int,
        name: data['name'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        email: data['email'] as String? ?? '',
      )).toList();
    } catch (e) {
      print('❌ فشل استرجاع المستخدمين: $e');
      return [];
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    print('🔍 التحقق من وجود البريد الإلكتروني: $email');
    final db = await database;

    try {
      final result = await db.query(
        userTable,
        where: 'email = ?',
        whereArgs: [email],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('❌ فشل التحقق من البريد الإلكتروني: $e');
      return false;
    }
  }

  // ==============================================
  // ✅ دوال SharedPreferences
  // ==============================================

  @override
  Future<void> saveUserToCache(UserEntity user) async {
    print('💾 حفظ بيانات المستخدم في SharedPreferences');
    print('👤 المستخدم: ID=${user.id}, Name=${user.name}, Email=${user.email}');

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userIdKey, user.id.toString());
      await prefs.setString(_userNameKey, user.name);
      await prefs.setString(_userPhoneKey, user.phone);
      await prefs.setString(_userEmailKey, user.email);

      print('✅ تم حفظ البيانات في SharedPreferences بنجاح');
    } catch (e) {
      print('❌ خطأ في حفظ البيانات في SharedPreferences: $e');
      throw CacheException('فشل في حفظ بيانات المستخدم');
    }
  }



  @override
  Future<UserEntity?> getCachedUser() async {
    print('📂 استرجاع بيانات المستخدم من SharedPreferences');

    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        print('❌ المستخدم غير مسجل دخوله');
        return null;
      }

      final userId = prefs.getString(_userIdKey);
      final userName = prefs.getString(_userNameKey);
      final userPhone = prefs.getString(_userPhoneKey);
      final userEmail = prefs.getString(_userEmailKey);

      if (userId == null || userName == null || userEmail == null) {
        print('❌ بيانات المستخدم غير مكتملة');
        return null;
      }

      print('✅ تم استرجاع بيانات المستخدم');

      return UserModel(
        id: int.parse(userId),
        name: userName,
        phone: userPhone ?? '',
        email: userEmail,
      );
    } catch (e) {
      print('❌ خطأ في استرجاع بيانات المستخدم: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    print('🔍 التحقق من حالة تسجيل الدخول');

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      print('📊 حالة تسجيل الدخول: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('❌ خطأ في التحقق من حالة تسجيل الدخول: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    print('🚪 تسجيل الخروج');

    try {
      final prefs = await SharedPreferences.getInstance();

      // مسح جميع بيانات المستخدم
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userEmailKey);

      print('✅ تم تسجيل الخروج ومسح البيانات بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
    }
  }

  // ==============================================
  // ✅ دوال إضافية مفيدة
  // ==============================================

  // دالة للتحقق من الجداول
  Future<void> verifyTables() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    );

    print('📊 الجداول الموجودة في قاعدة البيانات:');
    if (result.isEmpty) {
      print('❌ لا توجد جداول!');
    } else {
      for (var table in result) {
        print('  ✅ ${table['name']}');
      }
    }
  }

  // دالة لإعادة تعيين قاعدة البيانات
  Future<void> resetDatabase() async {
    print('🗑️ حذف قاعدة البيانات...');
    try {
      String path = join(await getDatabasesPath(), 'store_database.db');
      await deleteDatabase(path);
      _database = null;
      print('✅ تم حذف قاعدة البيانات');

      // إعادة إنشاء
      await database;
      print('✅ تم إعادة إنشاء قاعدة البيانات');
    } catch (e) {
      print('❌ فشل حذف قاعدة البيانات: $e');
    }
  }

  // دالة لطباعة جميع البيانات
  Future<void> printAllData() async {
    final db = await database;

    print('\n📊 ===== جميع البيانات =====');

    // جلب جميع المستخدمين
    final users = await db.query(userTable);
    print('\n👤 المستخدمين:');
    for (var user in users) {
      print('  - ID: ${user['id']}, Name: ${user['name']}, Email: ${user['email']}');
    }

    // جلب جميع المنتجات
    final products = await db.query(productTable);
    print('\n📦 المنتجات:');
    for (var product in products) {
      print('  - ID: ${product['id']}, Name: ${product['name']}, Price: ${product['price']}');
    }

    print('\n============================\n');
  }

  // دالة للحصول على منتجات مستخدم معين
  Future<List<Map<String, dynamic>>> getUserProducts(int userId) async {
    print('📦 استرجاع منتجات المستخدم رقم: $userId');
    final db = await database;

    try {
      final result = await db.query(
        productTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );

      print('✅ تم استرجاع ${result.length} منتج');
      return result;
    } catch (e) {
      print('❌ فشل استرجاع المنتجات: $e');
      return [];
    }
  }
}