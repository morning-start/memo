import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String sqlCreateTable(String tableName, Map<String, String> columns) {
  String columnsDefinition =
      columns.entries.map((entry) => "${entry.key} ${entry.value}").join(', ');
  return "CREATE TABLE $tableName ($columnsDefinition)";
}

const String dbName = 'memo.db';

Future<Database> initializeDatabase(String createSql, [int version = 1]) async {
  return await openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (db, version) {
      return db.execute(createSql);
    },
    version: version,
  );
}
