import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo_model.dart';
import '../models/countdown_model.dart';

class DatabaseHelper {
  final String _dbName = 'memo.db';
  final int _dbVersion = 1;
  final List<String> _createSqlList = [
    Todo.sql,
    Countdown.sql,
  ];

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDatabase(_createSqlList);
    return _database!;
  }

  Future<Database> _initDatabase(List<String> createSqlList) async {
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        for (var createSql in createSqlList) {
          await db.execute(createSql);
        }
      },
      version: _dbVersion,
    );
  }
}
