
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
