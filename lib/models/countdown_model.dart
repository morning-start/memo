import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../tools/db_seeder.dart';

class Countdown {
  final String id; // 唯一标识符
  String title; // 任务标题
  DateTime startTime; // 任务开始时间
  Duration duration; // 重复间隔时长
  bool isRecurring; // 是否重复
  bool isCompleted; // 任务是否完成

  // 表名常量
  static const String tableName = 'countdowns';

  // 列定义
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',
    'title': 'TEXT',
    'startTime': 'TEXT',
    'duration': 'INTEGER',
    'isRecurring': 'INTEGER',
    'isCompleted': 'INTEGER',
  };

  // 构造函数，初始化任务对象
  Countdown({
    String? id,
    required this.title,
    required this.startTime,
    required this.duration,
    this.isRecurring = false,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  // 生成 CREATE TABLE 语句
  static String get toSqlCreateTable => sqlCreateTable(tableName, _columns);

  // 重启任务
  void restart() {
    isCompleted = false;
    startTime = DateTime.now();
  }

  void changeStatus() {
    isCompleted = !isCompleted;
  }

  void update(String newTitle, DateTime newStartTime, Duration newDuration,
      bool newIsRecurring) {
    title = newTitle;
    startTime = newStartTime;
    duration = newDuration;
    isRecurring = newIsRecurring;
  }

  /// 将当前对象转换为Map类型，以便于存储或传输
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
