import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diagnosis.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT,
            diagnosis TEXT,
            plan TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertRecord(String patientId, String diagnosis, String plan) async {
    final db = await database;
    await db.insert('records', {
      'patient_id': patientId,
      'diagnosis': diagnosis,
      'plan': plan,
    }, conflictAlgorithm: ConflictAlgorithm.replace); // 덮어쓰기 허용
  }

  static Future<Map<String, dynamic>?> getRecord(String patientId) async {
    final db = await database;
    final result = await db.query(
      'records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }
}
