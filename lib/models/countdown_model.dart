import 'package:memo/models/base_model.dart';

/// 表示一个倒计时任务的类。
///
/// 包含任务的唯一标识符、标题、开始时间、持续时间、是否重复和是否完成的状态。
class Countdown extends BaseModel {
  DateTime startTime;
  Duration duration;
  bool isRecurring;

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
    required String title,
    required this.startTime,
    required this.duration,
    this.isRecurring = false,
    bool isCompleted = false,
  }) : super(id: id, title: title, isCompleted: isCompleted);

  /// 获取创建表SQL语句。
  ///
  /// 返回一个SQL语句，用于创建名为'countdowns'的表，包含指定的列。
  /// 列包括'id'、'title'、'startTime'、'duration'、'isRecurring'和'isCompleted'。
  static String get sql => BaseModel.sqlCreateTable(tableName, _columns);

  /// 重启倒计时任务。
  ///
  /// 将任务的完成状态设置为false，并将开始时间更新为当前时间。
  void _restart() {
    isCompleted = false;
    startTime = DateTime.now();
  }

  @override
  void changeStatus() {
    super.changeStatus();
    if (isCompleted && isRecurring) {
      _restart();
    }
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
      'duration': duration.inDays, // 确保持续时间以天为单位存储
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
      duration: Duration(days: map['duration']), // 确保持续时间以天为单位读取
      isRecurring: map['isRecurring'] == 1,
      isCompleted: map['isCompleted'] == 1,
    );
  }

}
