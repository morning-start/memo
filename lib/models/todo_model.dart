import 'dart:convert';

import '../tools/db_seeder.dart';
import 'package:uuid/uuid.dart';

/// 表示一个待办事项的类
/// 包含唯一标识符、标题、截止日期和完成状态

class Todo {
  // 唯一标识符
  final String id;
  // 标题
  String title;
  // 截止日期
  DateTime deadline;
  // 完成状态
  bool isCompleted;

  Todo({
    String? id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
  }) : id = id ?? Uuid().v4(); // 如果 id 为空，则生成新的 id

  // 表名常量
  static const String tableName = 'todos';

  // 列定义
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'title': 'TEXT',
    'deadline': 'TEXT',
    'isCompleted': 'INTEGER'
  };

  // 生成 CREATE TABLE 语句
  static String get toSqlCreateTable => sqlCreateTable(tableName, _columns);

  /// 将当前对象转换为Map类型，以便于存储或传输
  ///
  /// 此方法用于将对象的属性转换为一个Map对象每个属性都以键值对的形式存储
  /// 特别注意的是，[deadline]属性是一个DateTime对象，它被转换为ISO 8601字符串格式
  /// 这样做是为了便于在不同的平台或数据库中存储和传输时间信息
  /// [isCompleted]属性是一个布尔值，它被转换为整数(1或0)以便于存储
  /// 这种转换是因为某些数据库系统不直接支持布尔值的存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  void changeStatus() {
    isCompleted = !isCompleted;
  }

  void update(String newTitle, DateTime newDeadline) {
    title = newTitle;
    deadline = newDeadline;
  }

  /// 根据一个Map对象创建一个新的Todo实例。
  ///
  /// 此工厂构造函数用于将一个包含待办事项数据的Map转换为Todo对象。
  /// 它从Map中提取'id'、'title'、'deadline'和'isCompleted'字段，并使用这些值初始化新的Todo对象。
  ///
  /// 参数:
  ///   - map: 包含待办事项数据的Map <String, dynamic> 对象。必须包含'id'、'title'、'deadline'和'isCompleted'键。
  ///
  /// 返回值:
  ///   一个新的Todo对象，其属性由提供的Map中的值初始化。
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  /// 将对象转换为JSON字符串
  ///
  /// 此方法用于序列化对象，使其可以轻松地存储或传输
  /// 它首先将对象转换为Map，然后将该Map转换为JSON字符串
  ///
  /// 返回: 对象的JSON字符串表示
  String toJson() {
    return jsonEncode(toMap());
  }

  /// 创建一个Todo对象的工厂构造函数
  ///
  /// 此构造函数接受一个JSON字符串作为输入，并将其解析为一个Todo对象
  /// 它首先将JSON字符串解码为一个Dart的Map对象，然后调用Todo.fromMap工厂构造函数
  /// 来创建并返回一个Todo对象
  factory Todo.fromJson(String jsonString) {
    // 将JSON字符串解码为一个Dart的Map对象
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));

    // 使用解码后的Map对象来创建并返回一个Todo对象
    return Todo.fromMap(json);
  }
}
