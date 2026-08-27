import 'package:uuid/uuid.dart';

import 'package:memo/models/task_model.dart';

/// 规律事项数据模型
///
/// 长期/周期任务的最小单元，是应用的核心模型。代表"每 X 时间做一次"的
/// 规律事件，例如「每1月换一次滤芯」「每年体检一次」。
///
/// 核心设计 —— 自动重置、减轻记忆负担：
/// 用户在设定任务时只需给出"周期"和"本次完成时间"，应用自动推算
/// `下次到期 = 上次完成时间 + 周期`。用户勾选"完成"后，应用把
/// `lastCompletedAt` 更新为当前时间，下次到期自动归零向后滚动，
/// 用户无需死记"下次是什么时候"。
///
/// 其它能力：
/// - 归属分组（groupId 为空表示未分组的独立任务）
/// - 暂停/恢复（isPaused），暂停的任务不再参与提醒与概览统计
/// - 独立预警提前量（warnLeadDays），默认提前 1 周，可按任务自行调整
///   （一年周期的大项可设为提前 1 个月，简单事项默认 1 周）
class Routine {
  /// 唯一标识符
  final String id;

  /// 任务标题，例如「更换净水器滤芯」
  String title;

  /// 所属分组 id，null 表示未分组
  String? groupId;

  /// 周期（天）。例如每1月=30、每3月=91、每1年=365
  int intervalDays;

  /// 上次完成时间。null 表示从未完成过，此时以 createdAt 作为锚点。
  DateTime? lastCompletedAt;

  /// 首次创建时间，作为从未完成任务的下次到期锚点
  final DateTime createdAt;

  /// 是否已暂停。暂停后不参与提醒与概览统计
  bool isPaused;

  /// 预警提前量（天），默认 7（提前一周）。
  /// 到期前 warnLeadDays 天即进入"即将到期/需准备"状态并出现在概览中。
  int warnLeadDays;

  /// 数据库表名
  static const String tableName = 'routines';

  /// 数据库表结构
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'title': 'TEXT NOT NULL',
    'groupId': 'TEXT',
    'intervalDays': 'INTEGER NOT NULL',
    'lastCompletedAt': 'TEXT',
    'createdAt': 'TEXT NOT NULL',
    'isPaused': 'INTEGER DEFAULT 0',
    'warnLeadDays': 'INTEGER DEFAULT 7',
  };

  /// 构造函数
  Routine({
    String? id,
    required this.title,
    this.groupId,
    required this.intervalDays,
    DateTime? lastCompletedAt,
    DateTime? createdAt,
    this.isPaused = false,
    this.warnLeadDays = 7,
  })  : id = id ?? const Uuid().v4(),
        lastCompletedAt = lastCompletedAt,
        createdAt = createdAt ?? DateTime.now();

  /// 建表 SQL
  static String get sql => TaskModel.sqlCreateTable(tableName, _columns);

  /// 计算下次到期时间：上次完成（无则创建时点）+ 周期
  DateTime get nextDue {
    return (lastCompletedAt ?? createdAt).add(Duration(days: intervalDays));
  }

  /// 序列化为 Map。lastCompletedAt 为 null 时存空字符串
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'groupId': groupId,
      'intervalDays': intervalDays,
      'lastCompletedAt': lastCompletedAt?.toIso8601String() ?? '',
      'createdAt': createdAt.toIso8601String(),
      'isPaused': isPaused ? 1 : 0,
      'warnLeadDays': warnLeadDays,
    };
  }

  /// 从 Map 还原（兼容空字符串表示未完成）
  factory Routine.fromMap(Map<String, dynamic> map) {
    final lastStr = map['lastCompletedAt'] as String?;
    final lastTime =
        (lastStr == null || lastStr.isEmpty) ? null : DateTime.tryParse(lastStr);

    return Routine(
      id: map['id'],
      title: map['title'],
      groupId: map['groupId'] as String?,
      intervalDays: map['intervalDays'] as int,
      lastCompletedAt: lastTime,
      createdAt: DateTime.parse(map['createdAt']),
      isPaused: map['isPaused'] == 1,
      warnLeadDays: (map['warnLeadDays'] as int?) ?? 7,
    );
  }
}