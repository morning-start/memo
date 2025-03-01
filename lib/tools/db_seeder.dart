import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库名称
const String dbName = 'memo.db';
const int dbVersion = 1;

/// 初始化数据库并返回 Database 对象。
///
/// 如果数据库文件不存在，则创建新数据库并执行传入的 SQL 语句列表。
///
/// 参数：
///   - createSqlList - 创建表的 SQL 语句列表。
///   - version - 数据库版本号，默认为 1。
Future<Database> initializeDatabase(List<String> createSqlList) async {
  return await openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (db, version) async {
      for (var createSql in createSqlList) {
        await db.execute(createSql);
      }
    },
    version: dbVersion,
  );
}

Future<Database> openTable(String sql) async {
  return await openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (db, version) async {
      await db.execute(sql);
    },
    version: dbVersion,
  );
}

/// 生成创建表的 SQL 语句。
///
/// 参数：
///   - tableName - 表的名称。
///   - columns - 表的列定义，键为列名，值为列的数据类型。
///
/// 返回一个 SQL 语句字符串，用于创建指定名称和列定义的表。
String sqlCreateTable(String tableName, Map<String, String> columns) {
  String columnsDefinition =
      columns.entries.map((entry) => "${entry.key} ${entry.value}").join(', ');
  return "CREATE TABLE IF NOT EXISTS $tableName ($columnsDefinition)";
}
