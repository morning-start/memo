import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../tools/db_seeder.dart';

class Countdown {
  final String id; // 唯一标识符
  final String title; // 任务标题
  final DateTime? deadline; // 截止日期
  final bool isRecurring; // 是否重复
  final Duration? duration; // 重复间隔时长

  // 表名常量
  static const String _tableName = 'countdowns';

  // 列定义
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'title': 'TEXT',
    'deadline': 'TEXT',
    'isRecurring': 'INTEGER',
    'duration': 'INTEGER'
  };

  // 构造函数，初始化任务对象
  Countdown({
    String? id,
    required this.title,
    this.deadline,
    this.isRecurring = false,
    this.duration = const Duration(days: 0),
  }) : id = id ?? const Uuid().v4() {
    // 如果任务不是重复的且没有截止日期，则抛出异常
    if (!isRecurring && deadline == null) {
      throw ArgumentError(
          'If isRecurring is false, deadline must be provided.');
    }
    // 如果任务是重复的且没有重复间隔时长，则抛出异常
    if (isRecurring && duration == null) {
      throw ArgumentError('If isRecurring is true, duration must be provided.');
    }
  }

  // 生成 CREATE TABLE 语句
  String get toSqlCreateTable => sqlCreateTable(_tableName, _columns);

  /// 将当前对象转换为Map类型，以便于存储或传输
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'duration': duration?.inSeconds,
    };
  }

  /// 根据一个Map对象创建一个新的Countdown实例。
  factory Countdown.fromMap(Map<String, dynamic> map) {
    return Countdown(
      id: map['id'],
      title: map['title'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isRecurring: map['isRecurring'] == 1,
      duration: map['duration'] != null ? Duration(seconds: map['duration']) : null,
    );
  }

  /// 将对象转换为JSON字符串
  String toJson() {
    return jsonEncode(toMap());
  }

  /// 创建一个Countdown对象的工厂构造函数
  factory Countdown.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    return Countdown.fromMap(json);
  }
}