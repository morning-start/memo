import 'dart:convert';

import 'package:uuid/uuid.dart';

/// 任务数据模型基类
///
/// 定义了所有任务类型的通用属性和行为，作为任务系统的抽象基础。
/// 采用抽象类设计，强制子类实现特定的序列化和反序列化方法。
///
/// 设计原则：
/// - 使用抽象类定义通用接口，确保类型安全
/// - 提供默认实现和工具方法，减少重复代码
/// - 遵循开闭原则，对扩展开放，对修改封闭
/// - 支持多种序列化格式（Map、JSON）
///
/// 适用场景：
/// - 作为倒计时任务(Countdown)和待办事项(Todo)的基类
/// - 需要统一任务接口的多类型任务管理系统
/// - 需要持久化存储的任务数据模型
abstract class TaskModel {
  /// 任务唯一标识符
  /// 
  /// 使用 UUID v4 格式生成全局唯一标识符，确保任务在系统中的唯一性。
  /// 该标识符在创建时自动生成，也可手动指定以支持数据迁移。
  final String id;
  
  /// 任务标题
  /// 
  /// 任务的简短描述或名称，用于在UI中显示和用户识别。
  /// 该属性为可变类型，允许用户修改任务标题。
  String title;
  
  /// 任务完成状态
  /// 
  /// 表示任务是否已完成，true 表示已完成，false 表示未完成。
  /// 默认为 false，表示新创建的任务处于未完成状态。
  bool isCompleted;

  /// 构造函数
  /// 
  /// 创建一个新的任务实例。
  /// 
  /// 参数:
  ///   - id: 任务唯一标识符，可选参数，不提供时自动生成 UUID v4
  ///   - title: 任务标题，必填参数
  ///   - isCompleted: 任务完成状态，可选参数，默认为 false
  TaskModel({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  /// 将任务对象转换为 Map
  /// 
  /// 抽象方法，必须由子类实现，用于将任务对象序列化为 Map 格式。
  /// 该方法主要用于数据库存储和网络传输。
  /// 
  /// 实现要求：
  /// - 包含所有必要的任务属性
  /// - 处理复杂类型的转换（如 DateTime → 字符串）
  /// - 确保数据类型与数据库表结构匹配
  /// 
  /// 返回值：包含任务所有属性的 Map 对象
  Map<String, dynamic> toMap();

  /// 从 Map 创建任务对象
  /// 
  /// 抽象工厂方法，必须由子类实现，用于从 Map 数据反序列化任务对象。
  /// 该方法主要用于从数据库查询结果和网络数据创建任务实例。
  /// 
  /// 实现要求：
  /// - 处理所有必要的任务属性
  /// - 正确转换数据类型（如字符串 → DateTime）
  /// - 处理可能的空值和默认值
  /// 
  /// 参数:
  ///   - map: 包含任务属性的 Map 对象
  /// 
  /// 返回值：新的任务实例
  /// 
  /// 异常：如果 Map 中缺少必要字段或格式不正确，应抛出相应异常
  factory TaskModel.fromMap(Map<String, dynamic> map) =>
      throw UnimplementedError();

  /// 切换任务完成状态
  /// 
  /// 将任务的完成状态从 true 切换为 false，或从 false 切换为 true。
  /// 这是一个便捷方法，简化了状态切换的操作。
  /// 
  /// 执行效果：
  /// - 如果当前为未完成(isCompleted=false)，则变为已完成(isCompleted=true)
  /// - 如果当前为已完成(isCompleted=true)，则变为未完成(isCompleted=false)
  /// 
  /// 注意：此方法直接修改对象状态，不会自动保存到数据库
  void changeStatus() {
    isCompleted = !isCompleted;
  }

  /// 将任务对象转换为 JSON 字符串
  /// 
  /// 将任务对象序列化为 JSON 格式的字符串，便于网络传输和持久化存储。
  /// 该方法内部调用 toMap() 方法获取任务数据，然后使用 jsonEncode 转换。
  /// 
  /// 转换流程：
  /// 1. 调用 toMap() 方法获取 Map 格式的任务数据
  /// 2. 使用 jsonEncode 将 Map 转换为 JSON 字符串
  /// 
  /// 返回值：表示任务的 JSON 字符串
  /// 
  /// 异常：如果 toMap() 返回的数据包含不支持 JSON 序列化的类型，可能抛出异常
  String toJson() {
    return jsonEncode(toMap());
  }

  /// 从 JSON 字符串创建任务对象
  /// 
  /// 将 JSON 字符串反序列化为任务对象，用于从网络数据或持久化存储恢复任务。
  /// 该方法内部解析 JSON 字符串为 Map，然后调用 fromMap() 创建任务实例。
  /// 
  /// 转换流程：
  /// 1. 使用 jsonDecode 将 JSON 字符串解析为 Map
  /// 2. 调用 fromMap() 方法从 Map 创建任务实例
  /// 
  /// 参数:
  ///   - jsonString: 表示任务的 JSON 字符串
  /// 
  /// 返回值：新的任务实例
  /// 
  /// 异常：
  ///   - 如果 JSON 字符串格式不正确，抛出 FormatException
  ///   - 如果 fromMap() 实现抛出异常，该异常会继续传播
  factory TaskModel.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    return TaskModel.fromMap(json);
  }

  /// 生成创建表的 SQL 语句
  /// 
  /// 静态工具方法，用于根据表名和列定义生成完整的 SQL 建表语句。
  /// 该方法提供了统一的 SQL 生成逻辑，确保所有任务表使用一致的创建语法。
  /// 
  /// 参数：
  ///   - tableName: 数据库表的名称
  ///   - columns: 表的列定义，键为列名，值为列的数据类型
  /// 
  /// 返回值：完整的 CREATE TABLE SQL 语句字符串
  /// 
  /// 示例：
  /// ```dart
  /// final columns = {
  ///   'id': 'TEXT PRIMARY KEY',
  ///   'title': 'TEXT NOT NULL',
  ///   'isCompleted': 'INTEGER DEFAULT 0'
  /// };
  /// final sql = TaskModel.sqlCreateTable('tasks', columns);
  /// // 结果: "CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, title TEXT NOT NULL, isCompleted INTEGER DEFAULT 0)"
  /// ```
  /// 
  /// 注意：
  /// - 生成的 SQL 语句使用 "CREATE TABLE IF NOT EXISTS" 语法
  /// - 列定义按 Map 中的顺序排列
  /// - 不包含外键约束或高级表选项，如有需要可在子类中扩展
  static String sqlCreateTable(String tableName, Map<String, String> columns) {
    String columnsDefinition = columns.entries
        .map((entry) => "${entry.key} ${entry.value}")
        .join(', ');
    return "CREATE TABLE IF NOT EXISTS $tableName ($columnsDefinition)";
  }
}
