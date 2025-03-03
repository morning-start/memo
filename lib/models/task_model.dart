import 'dart:convert';

import 'package:uuid/uuid.dart';

abstract class TaskModel {
  final String id;
  String title;
  bool isCompleted;

  TaskModel({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  // 抽象方法，需要子类实现
  Map<String, dynamic> toMap();

  // 抽象方法，需要子类实现
  factory TaskModel.fromMap(Map<String, dynamic> map) =>
      throw UnimplementedError();

  // 切换完成状态
  void changeStatus() {
    isCompleted = !isCompleted;
  }

  // 将对象转换为JSON字符串
  String toJson() {
    return jsonEncode(toMap());
  }

  // 从JSON字符串创建对象
  factory TaskModel.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    return TaskModel.fromMap(json);
  }

  /// 生成创建表的 SQL 语句。
  ///
  /// 参数：
  ///   - tableName - 表的名称。
  ///   - columns - 表的列定义，键为列名，值为列的数据类型。
  ///
  /// 返回一个 SQL 语句字符串，用于创建指定名称和列定义的表。
  static String sqlCreateTable(String tableName, Map<String, String> columns) {
    String columnsDefinition = columns.entries
        .map((entry) => "${entry.key} ${entry.value}")
        .join(', ');
    return "CREATE TABLE IF NOT EXISTS $tableName ($columnsDefinition)";
  }
}
