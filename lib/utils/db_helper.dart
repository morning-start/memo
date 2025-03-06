import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:memo/models/countdown_model.dart';
import 'package:memo/models/todo_model.dart';

class DatabaseHelper {
  static final String dbName = 'memo.db';
  static final int dbVersion = 1;
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

  static Future<String> getPath() async {
    // 获取应用的数据库目录路径
    String databasesPath = await getDatabasesPath();
    // 拼接数据库文件名
    String dbPath = join(databasesPath, dbName);
    return dbPath;
  }

  /// 初始化数据库并返回 Database 对象。
  ///
  /// 如果数据库文件不存在，则创建新数据库并执行传入的 SQL 语句列表。
  ///
  /// 参数：
  ///   - createSqlList - 创建表的 SQL 语句列表。
  Future<Database> _initDatabase(List<String> createSqlList) async {
    return await openDatabase(
      await getPath(),
      onCreate: (db, version) async {
        for (var createSql in createSqlList) {
          await db.execute(createSql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // TODO: 升级数据库逻辑
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        // TODO: 降级数据库逻辑
      },
      onOpen: (db) async {
        // TODO: 打开数据库逻辑
      },
      version: dbVersion,
    );
  }

  /// 关闭数据库连接。
  Future<void> close() async {
    final db = await _instance.db;
    await db.close();
  }

  /// 向指定表中插入一行数据。
  ///
  /// 参数：
  ///   - table - 表名。
  ///   - row - 要插入的数据行，键值对形式。
  Future<void> insert(String table, Map<String, dynamic> row) async {
    final db = await _instance.db;
    await db.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 查询指定表中的数据。
  ///
  /// 参数：
  ///   - table - 表名。
  ///   - distinct - 是否返回唯一值。
  ///   - columns - 要查询的列。
  ///   - where - 查询条件。
  ///   - whereArgs - 查询条件中的参数。
  ///   - groupBy - 分组条件。
  ///   - having - 分组条件中的过滤条件。
  ///   - orderBy - 排序条件。
  ///   - limit - 返回的最大行数。
  ///   - offset - 跳过的行数。
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
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

  /// 更新指定表中的数据。
  ///
  /// 参数：
  ///   - table - 表名。
  ///   - values - 要更新的数据，键值对形式。
  ///   - where - 更新条件。
  ///   - whereArgs - 更新条件中的参数。
  ///   - conflictAlgorithm - 冲突解决算法。
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

  /// 删除指定表中的数据。
  ///
  /// 参数：
  ///   - table - 表名。
  ///   - where - 删除条件。
  ///   - whereArgs - 删除条件中的参数。
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
