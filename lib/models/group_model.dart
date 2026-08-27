import 'package:uuid/uuid.dart';

import 'package:memo/models/task_model.dart';

/// 分组数据模型
///
/// 分组是"规律事项"的容器，用来承载一件大事情拆解出的多个周期子项。
/// 分组本身不强制拥有周期，只是一个可展开/收起的归类层级。
///
/// 示例：净水器（分组）
///   - 滤芯一 · 每1月
///   - 滤芯二 · 每3月
///   - 滤芯三 · 每6月
///
/// 设计说明：
/// - 采用两级层级（分组 -> 规律项），满足大多数实际场景
/// - 分组不直接参与周期计算，聚合状态由子项推导
class Group {
  /// 分组唯一标识符
  final String id;

  /// 分组名称
  String name;

  /// 排序权重（越大越靠前），预留能力
  int sortOrder;

  /// 创建时间，作为稳定锚点
  final DateTime createdAt;

  /// 数据库表名
  static const String tableName = 'groups';

  /// 数据库表结构
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'name': 'TEXT NOT NULL',
    'sortOrder': 'INTEGER DEFAULT 0',
    'createdAt': 'TEXT NOT NULL',
  };

  /// 构造函数
  Group({
    String? id,
    required this.name,
    this.sortOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// 建表 SQL
  static String get sql => TaskModel.sqlCreateTable(tableName, _columns);

  /// 序列化为数据库 Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
      };

  /// 从数据库 Map 反序列化
  factory Group.fromMap(Map<String, dynamic> map) => Group(
        id: map['id'],
        name: map['name'],
        sortOrder: map['sortOrder'] ?? 0,
        createdAt: DateTime.parse(map['createdAt']),
      );
}