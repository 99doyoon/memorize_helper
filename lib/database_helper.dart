import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "WordDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'word_table';

  static final columnId = '_id';
  static final columnWord = 'word';
  static final columnMeaning = 'meaning';

  // 싱글톤 클래스 만들기
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // 데이터베이스가 없으면 초기화해서 생성
    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화 및 열기
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // 데이터베이스 생성
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnWord TEXT NOT NULL,
            $columnMeaning TEXT NOT NULL
          )
          ''');
  }

  // 단어 추가
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // 모든 단어 조회
  Future<List<Map<String, dynamic>>> queryAllWords() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // 단어 업데이트
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // 단어 삭제
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
