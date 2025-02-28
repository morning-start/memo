String sqlCreateTable(String tableName, Map<String, String> columns) {
  String columnsDefinition =
      columns.entries.map((entry) => "${entry.key} ${entry.value}").join(', ');
  return "CREATE TABLE $tableName ($columnsDefinition)";
}
