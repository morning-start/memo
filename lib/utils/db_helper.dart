import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:memo/models/countdown_model.dart';
import 'package:memo/models/todo_model.dart';

/// 数据库辅助类
///
/// 提供应用程序的数据库操作接口，包括数据库的创建、查询、更新和删除等操作。
/// 使用单例模式确保全局只有一个数据库实例，避免多连接问题。
///
/// 功能特点：
/// - 自动创建数据库和表结构
/// - 提供基础的 CRUD 操作接口
/// - 支持数据库版本管理和升级
/// - 提供数据库连接管理和资源释放
///
/// 使用示例：
/// ```dart
/// // 获取数据库实例
/// final dbHelper = DatabaseHelper();
/// 
/// // 插入数据
/// await dbHelper.insert('todos', {'title': '学习Flutter', 'isCompleted': 0});
/// 
/// // 查询数据
/// final results = await dbHelper.query('todos', where: 'isCompleted = ?', whereArgs: [0]);
/// 
/// // 更新数据
/// await dbHelper.update('todos', {'isCompleted': 1}, where: 'id = ?', whereArgs: [1]);
/// 
/// // 删除数据
/// await dbHelper.delete('todos', where: 'id = ?', whereArgs: [1]);
/// ```
class DatabaseHelper {
  /// 数据库名称
  static final String dbName = 'memo.db';
  
  /// 数据库版本号
  static final int dbVersion = 1;
  
  /// 创建表的 SQL 语句列表
  final List<String> _createSqlList = [
    Todo.sql,      // 创建待办事项表
    Countdown.sql, // 创建倒计时表
  ];

  /// 单例实例
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  /// 工厂构造函数，返回单例实例
  factory DatabaseHelper() => _instance;
  
  /// 私有命名构造函数，用于创建单例
  DatabaseHelper._internal();

  /// 数据库实例，使用延迟初始化
  static Database? _database;

  /// 获取数据库实例
  /// 
  /// 如果数据库实例不存在，则初始化数据库并返回新实例。
  /// 
  /// 返回值：数据库实例
  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDatabase(_createSqlList);
    return _database!;
  }

  /// 获取数据库文件路径
  /// 
  /// 获取应用程序的数据库目录路径，并拼接数据库文件名。
  /// 
  /// 返回值：数据库文件的完整路径
  static Future<String> getPath() async {
    // 获取应用的数据库目录路径
    String databasesPath = await getDatabasesPath();
    // 拼接数据库文件名
    String dbPath = join(databasesPath, dbName);
    return dbPath;
  }

  /// 初始化数据库并返回 Database 对象
  ///
  /// 如果数据库文件不存在，则创建新数据库并执行传入的 SQL 语句列表。
  ///
  /// 参数：
  ///   - createSqlList - 创建表的 SQL 语句列表
  /// 
  /// 返回值：初始化完成的数据库实例
  Future<Database> _initDatabase(List<String> createSqlList) async {
    return await openDatabase(
      await getPath(),
      onCreate: (db, version) async {
        // 执行所有创建表的 SQL 语句
        for (var createSql in createSqlList) {
          await db.execute(createSql);
        }
      },
      version: dbVersion,
    );
  }

  /// 关闭数据库连接
  /// 
  /// 关闭数据库连接并释放相关资源。
  /// 建议在应用程序退出时调用此方法。
  Future<void> close() async {
    final db = await _instance.db;
    await db.close();
  }

  /// 向指定表中插入一行数据
  ///
  /// 如果插入的数据与现有数据冲突，则替换现有数据。
  ///
  /// 参数：
  ///   - table - 表名
  ///   - row - 要插入的数据行，键值对形式
  /// 
  /// 使用示例：
  /// ```dart
  /// await dbHelper.insert('todos', {
  ///   'title': '学习Flutter',
  ///   'isCompleted': 0,
  ///   'deadline': DateTime.now().millisecondsSinceEpoch,
  /// });
  /// ```
  Future<void> insert(String table, Map<String, dynamic> row) async {
    final db = await _instance.db;
    await db.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace, // 冲突时替换现有数据
    );
  }

  /// 查询指定表中的数据
  ///
  /// 支持多种查询条件，包括排序、分组、限制结果数量等。
  ///
  /// 参数：
  ///   - table - 表名
  ///   - distinct - 是否返回唯一值
  ///   - columns - 要查询的列
  ///   - where - 查询条件
  ///   - whereArgs - 查询条件中的参数
  ///   - groupBy - 分组条件
  ///   - having - 分组条件中的过滤条件
  ///   - orderBy - 排序条件
  ///   - limit - 返回的最大行数
  ///   - offset - 跳过的行数
  /// 
  /// 返回值：查询结果列表，每个元素是一行数据的键值对
  /// 
  /// 使用示例：
  /// ```dart
  /// // 查询所有未完成的待办事项，按截止时间排序
  /// final results = await dbHelper.query(
  ///   'todos',
  ///   where: 'isCompleted = ?',
  ///   whereArgs: [0],
  ///   orderBy: 'deadline ASC',
  /// );
  /// 
  /// // 查询前10条记录
  /// final limitedResults = await dbHelper.query(
  ///   'todos',
  ///   limit: 10,
  /// );
  /// ```
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

  /// 更新指定表中的数据
  ///
  /// 根据条件更新表中的数据，支持冲突解决算法。
  ///
  /// 参数：
  ///   - table - 表名
  ///   - values - 要更新的数据，键值对形式
  ///   - where - 更新条件
  ///   - whereArgs - 更新条件中的参数
  ///   - conflictAlgorithm - 冲突解决算法
  /// 
  /// 返回值：受影响的行数
  /// 
  /// 使用示例：
  /// ```dart
  /// // 将ID为1的待办事项标记为已完成
  /// final affectedRows = await dbHelper.update(
  ///   'todos',
  ///   {'isCompleted': 1},
  ///   where: 'id = ?',
  ///   whereArgs: [1],
  /// );
  /// print('更新了 $affectedRows 行数据');
  /// ```
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

  /// 删除指定表中的数据
  ///
  /// 根据条件删除表中的数据，如果不提供条件则删除所有数据。
  ///
  /// 参数：
  ///   - table - 表名
  ///   - where - 删除条件
  ///   - whereArgs - 删除条件中的参数
  /// 
  /// 返回值：受影响的行数
  /// 
  /// 使用示例：
  /// ```dart
  /// // 删除ID为1的待办事项
  /// final affectedRows = await dbHelper.delete(
  ///   'todos',
  ///   where: 'id = ?',
  ///   whereArgs: [1],
  /// );
  /// print('删除了 $affectedRows 行数据');
  /// 
  /// // 删除所有已完成的待办事项
  /// await dbHelper.delete(
  ///   'todos',
  ///   where: 'isCompleted = ?',
  ///   whereArgs: [1],
  /// );
  /// ```
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

  /// 重新打开数据库，确保读取到最新的数据
  /// 
  /// 在某些情况下，如数据被外部修改时，可能需要重新打开数据库
  /// 以确保读取到最新的数据。此方法会关闭当前数据库连接，
  /// 然后重新初始化数据库。
  /// 
  /// 使用场景：
  /// - 数据库文件被外部进程修改
  /// - 需要强制刷新数据库缓存
  /// - 数据库升级或迁移后
  Future<void> reopenDatabase() async {
    // 关闭当前数据库连接
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    // 重新打开数据库
    _database = await _initDatabase(_createSqlList);
  }
}