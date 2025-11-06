import 'package:memo/models/task_model.dart';

/// 待办事项数据模型
///
/// 继承自 TaskModel 基类，专门表示具有截止日期的任务。
/// 该模型封装了待办事项的核心属性和行为，包括标题、截止日期等特有功能。
///
/// 设计特点：
/// - 支持设置明确的截止日期
/// - 提供数据库映射和序列化功能
/// - 遵循不可变性和函数式编程原则
/// - 简洁的API设计，便于日常任务管理
///
/// 使用场景：
/// - 日常任务清单管理
/// - 项目里程碑跟踪
/// - 个人日程安排
/// - 团队任务分配

class Todo extends TaskModel {
  /// 任务截止日期
  /// 
  /// 表示待办事项必须完成的时间点，用于任务优先级排序和提醒。
  /// 该属性为可变类型，允许用户调整任务截止日期。
  DateTime deadline;

  /// 构造函数
  /// 
  /// 创建一个新的待办事项实例。
  /// 
  /// 参数:
  ///   - id: 任务唯一标识符，可选参数，不提供时自动生成
  ///   - title: 任务标题，必填参数
  ///   - deadline: 任务截止日期，必填参数
  ///   - isCompleted: 是否已完成，可选参数，默认为 false
  Todo({
    super.id,
    required super.title,
    required this.deadline,
    super.isCompleted,
  });

  /// 待办事项数据库表名
  /// 
  /// 定义了在 SQLite 数据库中存储待办事项的表名。
  /// 该表包含 id、title、deadline 和 isCompleted 字段。
  static const String tableName = 'todos';

  /// 数据库表结构定义
  /// 
  /// 定义了待办事项表的所有列及其数据类型。
  /// 使用 Map 结构便于动态生成 SQL 语句和维护表结构。
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',           // 任务唯一标识符
    'title': 'TEXT NOT NULL',           // 任务标题，不允许为空
    'deadline': 'TEXT',                 // 截止日期，ISO8601 格式字符串
    'isCompleted': 'INTEGER DEFAULT 0'  // 是否完成，0表示false，1表示true
  };

  /// 获取创建待办事项表的 SQL 语句
  /// 
  /// 使用基类提供的 sqlCreateTable 方法生成完整的 SQL 语句。
  /// 该方法会根据表名和列定义创建符合 SQLite 语法的建表语句。
  /// 
  /// 返回值：完整的 CREATE TABLE SQL 语句字符串
  /// 
  /// 示例：
  /// ```sql
  /// CREATE TABLE IF NOT EXISTS todos (
  ///   id TEXT PRIMARY KEY,
  ///   title TEXT NOT NULL,
  ///   deadline TEXT,
  ///   isCompleted INTEGER DEFAULT 0
  /// )
  /// ```
  static String get sql => TaskModel.sqlCreateTable(tableName, _columns);

  /// 将待办事项对象转换为 Map
  /// 
  /// 实现数据库存储和网络传输所需的序列化功能。
  /// 将复杂类型转换为适合存储的简单类型。
  /// 
  /// 类型转换规则：
  /// - DateTime → ISO8601 格式字符串
  /// - bool → 0 或 1 的整数值
  /// 
  /// 转换说明：
  /// - deadline 属性转换为 ISO8601 格式字符串，确保跨平台兼容性
  /// - isCompleted 属性转换为整数，适配不支持布尔值的数据库系统
  /// 
  /// 返回值：包含所有任务属性的 Map 对象
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  /// 更新待办事项的详细信息
  /// 
  /// 修改待办事项的所有可变属性，用于编辑现有任务。
  /// 该方法直接修改对象属性，适用于任务编辑场景。
  /// 
  /// 参数:
  ///   - newTitle: 任务的新标题
  ///   - newDeadline: 任务的新截止日期
  /// 
  /// 注意：此方法不会自动保存到数据库，需要调用相应的数据访问方法
  void update(String newTitle, DateTime newDeadline) {
    title = newTitle;
    deadline = newDeadline;
  }

  /// 从 Map 创建待办事项对象
  /// 
  /// 实现数据库查询结果和网络传输数据的反序列化功能。
  /// 将存储的简单类型转换回原始复杂类型。
  /// 
  /// 类型转换规则：
  /// - ISO8601 格式字符串 → DateTime
  /// - 0 或 1 的整数值 → bool
  /// 
  /// 参数:
  ///   - map: 包含任务属性的 Map 对象，通常来自数据库查询结果
  /// 
  /// 返回值：新的 Todo 实例
  /// 
  /// 异常：
  ///   - 如果 Map 中缺少必要字段，可能导致键为 null 的错误
  ///   - 如果 deadline 字符串格式不正确，DateTime.parse 可能抛出 FormatException
  /// 
  /// 示例：
  /// ```dart
  /// final map = {
  ///   'id': '123e4567-e89b-12d3-a456-426614174000',
  ///   'title': '完成项目文档',
  ///   'deadline': '2023-12-31T23:59:59.000Z',
  ///   'isCompleted': 0
  /// };
  /// final todo = Todo.fromMap(map);
  /// ```
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
