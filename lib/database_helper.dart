import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('categories.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType
      )
      ''');
  }

  Future<void> addCategory(String name) async {
    final db = await instance.database;
    await db.insert('categories', {'name': name});
  }

  Future<List<String>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');

    return result.map((json) => json['name'] as String).toList();
  }

  // 카테고리 삭제 메서드
  Future<void> deleteCategory(String name) async {
    final db = await instance.database;
    // 'name' 열이 매개변수로 받은 이름과 일치하는 레코드를 삭제합니다.
    await db.delete(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
