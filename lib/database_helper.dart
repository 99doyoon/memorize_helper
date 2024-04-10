import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 'categories' 테이블 생성
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> addCategory(String name) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('categories', {'name': name});
      // 카테고리에 따른 단어 테이블 생성
      await txn.execute('''
        CREATE TABLE ${name}_words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          meaning TEXT NOT NULL
        )
      ''');
    });
  }

  Future<void> deleteCategory(String name) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'categories',
        where: 'name = ?',
        whereArgs: [name],
      );
      // 해당 카테고리의 단어 테이블 삭제
      await txn.execute('DROP TABLE IF EXISTS ${name}_words');
    });
  }

  Future<List<String>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', columns: ['name']);
    List<String> categories = result.map((c) => c['name'] as String).toList();
    return categories;
  }

  Future<void> addWord(String categoryName, String word, String meaning) async {
    final db = await instance.database;
    await db.insert('${categoryName}_words', {'word': word, 'meaning': meaning});
  }

  Future<List<Map<String, dynamic>>> getWords(String categoryName) async {
    final db = await instance.database;
    final result = await db.query('${categoryName}_words');
    return result;
  }

  Future<void> deleteWord(String categoryName, int wordId) async {
    final db = await instance.database;
    await db.delete(
      '${categoryName}_words',
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
