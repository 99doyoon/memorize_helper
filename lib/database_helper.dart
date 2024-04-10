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

    // 데이터베이스 버전을 2로 업데이트합니다.
    return await openDatabase(path, version: 2, onCreate: _createDB, onOpen: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    }, onUpgrade: _onUpgrade); // onUpgrade 콜백 추가
  }

// onUpgrade 콜백 구현
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1. 임시 테이블 생성 및 기존 데이터 복사
      await db.execute('''
      CREATE TEMPORARY TABLE words_backup(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        categoryId INTEGER
      )
    ''');
      await db.execute('''
      INSERT INTO words_backup SELECT id, word, meaning, categoryId FROM words
    ''');
      await db.execute('DROP TABLE words');

      // 2. 새로운 FOREIGN KEY 제약 조건을 포함하여 원래 테이블 재생성
      await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

      // 3. 임시 테이블에서 데이터를 원래 테이블로 복사하고 임시 테이블 삭제
      await db.execute('''
      INSERT INTO words SELECT id, word, meaning, categoryId FROM words_backup
    ''');
      await db.execute('DROP TABLE words_backup');
    }
  }


  Future _createDB(Database db, int version) async {
    // 'categories' 테이블 생성
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // 'words' 테이블 생성
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
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

    // 먼저, 삭제하려는 카테고리의 ID를 찾습니다.
    final List<Map<String, dynamic>> categories = await db.query(
      'categories',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
    );

    if (categories.isNotEmpty) {
      final id = categories.first['id'];

      // 찾은 ID를 가진 카테고리 삭제
      // 연결된 'words' 테이블의 단어들도 자동으로 삭제됩니다. (ON DELETE CASCADE 설정 필요)
      await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }



  Future<void> addWord(String word, String meaning) async {
    final db = await instance.database;
    await db.insert('words', {'word': word, 'meaning': meaning});
  }

  Future<List<Map<String, dynamic>>> getWords() async {
    final db = await instance.database;
    final result = await db.query('words');
    return result;
  }

  Future<void> deleteWord(String word) async {
    final db = await instance.database;
    await db.delete(
      'words',
      where: 'word = ?',
      whereArgs: [word],
    );
  }

  // 모든 단어를 가져오는 메서드
  Future<List<Map<String, dynamic>>> getALLWords() async {
    final db = await instance.database;
    final result = await db.query('words');
    return result;
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
