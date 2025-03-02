import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:memo/func/db_seeder.dart';


/// 表示一个倒计时任务的类。
///
/// 包含任务的唯一标识符、标题、开始时间、持续时间、是否重复和是否完成的状态。
class Countdown {
  final String id; // 唯一标识符
  String title; // 任务标题
  DateTime startTime; // 任务开始时间
  Duration duration; // 重复间隔时长
  bool isRecurring; // 是否重复
  bool isCompleted; // 任务是否完成

  /// 倒计时任务的表名。
  static const String tableName = 'countdowns';

  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'title': 'TEXT NOT NULL',
    'startTime': 'TEXT NOT NULL',
    'duration': 'INTEGER NOT NULL',
    'isRecurring': 'INTEGER NOT NULL',
    'isCompleted': 'INTEGER NOT NULL',
  };

  Countdown({
    String? id,
    required this.title,
    required this.startTime,
    required this.duration,
    this.isRecurring = false,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  /// 获取创建表SQL语句。
  ///
  /// 返回一个SQL语句，用于创建名为'countdowns'的表，包含指定的列。
  /// 列包括'id'、'title'、'startTime'、'duration'、'isRecurring'和'isCompleted'。
  static String get sql => sqlCreateTable(tableName, _columns);

  /// 重启倒计时任务。
  ///
  /// 将任务的完成状态设置为false，并将开始时间更新为当前时间。
  void restart() {
    isCompleted = false;
    startTime = DateTime.now();
  }

  /// 切换任务的完成状态。
  ///
  /// 如果任务已完成，则将其设置为未完成；如果任务未完成，则将其设置为已完成。
  void changeStatus() {
    isCompleted = !isCompleted;
  }

  /// 更新倒计时任务的详细信息。
  ///
  /// 参数:
  ///   - newTitle: 任务的新标题。
  ///   - newStartTime: 任务的新开始时间。
  ///   - newDuration: 任务的新持续时间。
  ///   - newIsRecurring: 任务的新重复状态。
  void update(String newTitle, DateTime newStartTime, Duration newDuration,
      bool newIsRecurring) {
    title = newTitle;
    startTime = newStartTime;
    duration = newDuration;
    isRecurring = newIsRecurring;
  }

  /// 将当前对象转换为Map类型，以便于存储或传输。
  ///
  /// 返回一个包含任务所有属性的Map对象。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'duration': duration.inDays,
      'isRecurring': isRecurring ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  /// 根据一个Map对象创建一个新的Countdown实例。
  ///
  /// 参数:
  ///   - map: 包含任务属性的Map对象。
  ///
  /// 返回一个新的Countdown实例。
  factory Countdown.fromMap(Map<String, dynamic> map) {
    return Countdown(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      duration: Duration(seconds: map['duration']),
      isRecurring: map['isRecurring'] == 1,
      isCompleted: map['isCompleted'] == 1,
    );
  }

  /// 将对象转换为JSON字符串。
  ///
  /// 返回一个表示当前对象的JSON字符串。
  String toJson() {
    return jsonEncode(toMap());
  }

  /// 创建一个Countdown对象的工厂构造函数。
  ///
  /// 参数:
  ///   - jsonString: 包含任务属性的JSON字符串。
  ///
  /// 返回一个新的Countdown实例。
  factory Countdown.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    return Countdown.fromMap(json);
  }
}
