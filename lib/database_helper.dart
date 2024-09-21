import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pressure_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE thresholds (
            id INTEGER PRIMARY KEY,
            lower_threshold REAL,
            upper_threshold REAL
          )
        ''');
        db.execute('''
          CREATE TABLE pressure_data (
            id INTEGER PRIMARY KEY,
            last_pressure REAL
          )
        ''');
      },
    );
  }

  Future<void> saveThresholds(double lower, double upper) async {
    final db = await database;
    await db.insert(
      'thresholds',
      {'lower_threshold': lower, 'upper_threshold': upper},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, double>> getThresholds() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('thresholds');
    if (results.isNotEmpty) {
      return {
        'lower': results.first['lower_threshold'],
        'upper': results.first['upper_threshold']
      };
    }
    return {'lower': 80.0, 'upper': 120.0}; // Значения по умолчанию
  }

  Future<void> saveLastPressure(double pressure) async {
    final db = await database;
    await db.insert(
      'pressure_data',
      {'last_pressure': pressure},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> getLastPressure() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('pressure_data');
    if (result.isNotEmpty) {
      return result.first['last_pressure'];
    }
    return null;
  }
}
