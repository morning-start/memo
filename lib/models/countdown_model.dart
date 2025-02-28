import 'package:uuid/uuid.dart';

class CountdownTask {
  final String id; // 唯一标识符
  final String title; // 任务标题
  final DateTime? deadline; // 截止日期
  final bool isRecurring; // 是否重复
  final Duration? duration; // 重复间隔时长

  // 构造函数，初始化任务对象
  CountdownTask({
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

  // 将任务对象序列化为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isRecurring': isRecurring,
      'duration': duration?.inMilliseconds,
    };
  }

  // 从JSON格式反序列化为任务对象
  factory CountdownTask.fromJson(Map<String, dynamic> json) {
    return CountdownTask(
      id: json['id'] as String,
      title: json['title'] as String,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      isRecurring: json['isRecurring'] as bool,
      duration: json['duration'] != null ? Duration(milliseconds: json['duration'] as int) : null,
    );
  }
}
