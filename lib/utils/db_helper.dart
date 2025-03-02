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

  /// 初始化数据库并返回 Database 对象。
  ///
  /// 如果数据库文件不存在，则创建新数据库并执行传入的 SQL 语句列表。
  ///
  /// 参数：
  ///   - createSqlList - 创建表的 SQL 语句列表。
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

  Future<Database> openTable(String sql) async {
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await db.execute(sql);
      },
      version: _dbVersion,
    );
  }

  Future<void> close() async {
    final db = await _instance.db;
    await db.close();
  }

  Future<void> insert(String table, Map<String, dynamic> row) async {
    final db = await _instance.db;
    await db.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  ) async {
    final db = await _instance.db;
    return await db.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await _instance.db;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _instance.db;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
