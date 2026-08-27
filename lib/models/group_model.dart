import 'package:uuid/uuid.dart';

import 'package:memo/models/task_model.dart';

/// 分组数据模型
///
/// 表示一组规律事项的容器，用于把"一件需要拆成细碎事项"的事情组织在一起。
/// 例如「净水器」分组下可包含「滤芯一（每1月）」「滤芯二（每3月）」等多个
/// 独立周期、独立自动重置的子项。分组本身不持有周期，只负责归类与聚合展示。
///
/// 设计要点：
/// - 只做容器，不强制有自己的周期
/// - 每个子项（Routine）拥有独立的周期与"下次到期"时间
/// - 分组展示时聚合子项状态（最近到期项、最高紧急度）
class Group {
  /// 分组唯一标识符
  final String id;

  /// 分组名称，例如「净水器」「空调滤网」
  String name;

  /// 创建时间，用于排序与稳定 id
  final DateTime createdAt;

  /// 数据库表名
  static const String tableName = 'groups';

  /// 数据库表结构
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'name': 'TEXT NOT NULL',
    'createdAt': 'TEXT NOT NULL',
  };

  /// 构造函数
  Group({
    String? id,
    required this.name,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// 建表 SQL
  static String get sql => TaskModel.sqlCreateTable(tableName, _columns);

  /// 序列化为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从 Map 还原
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// 重命名分组
  void rename(String newName) {
    name = newName.trim();
  }
}