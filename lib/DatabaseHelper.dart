import 'package:sqflite/sqflite.dart';

class DatabaseHelpertest {
  static Database? _database;





  Future<List<String>> getAllTables() async {
    final db = await getDatabase();

    // استعلام لجلب جميع الجداول (استثناء جداول النظام)
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    );

    return result.map((row) => row['name'] as String).toList();
  }

  // عرض الجداول في الكونسول
  Future<void> printAllTables() async {
    final tables = await getAllTables();

    print('=== عدد الجداول: ${tables.length} ===');
    for (var table in tables) {
      print('📊 $table');
    }
  }





  // عرض أعمدة جدول معين
  Future<List<Map<String, dynamic>>> getTableColumns(String tableName) async {
    final db = await getDatabase();
    
    // استخدام PRAGMA للحصول على معلومات الأعمدة
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    
    return result;
  }

  // عرض أسماء الأعمدة فقط
  Future<List<String>> getTableColumnNames(String tableName) async {
    final columns = await getTableColumns(tableName);
    return columns.map((col) => col['name'] as String).toList();
  }

  // طباعة تفاصيل الأعمدة بشكل منظم
  Future<void> printTableSchema(String tableName) async {
    final columns = await getTableColumns(tableName);
    
    print('=== أعمدة جدول $tableName ===');
    for (var col in columns) {
      print('''
        الاسم: ${col['name']}
        النوع: ${col['type']}
        ليس فارغاً: ${col['notnull'] == 1 ? 'نعم' : 'لا'}
        القيمة الافتراضية: ${col['dflt_value'] ?? 'لا يوجد'}
        مفتاح أساسي: ${col['pk'] == 1 ? 'نعم' : 'لا'}
        ------------------------------
      ''');
    }
  }

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      'store_data.db',
    );
    return _database!;
  }
}