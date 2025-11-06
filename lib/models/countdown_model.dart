import 'package:memo/models/task_model.dart';
import 'package:memo/utils/sustain.dart';

/// 倒计时任务数据模型
///
/// 继承自 TaskModel 基类，专门表示具有倒计时功能的任务。
/// 该模型封装了倒计时任务的核心属性和行为，包括开始时间、持续时间、
/// 循环设置等特有功能。
///
/// 设计特点：
/// - 支持一次性倒计时和循环倒计时两种模式
/// - 完成后可自动重启循环任务
/// - 提供数据库映射和序列化功能
/// - 遵循不可变性和函数式编程原则
///
/// 使用场景：
/// - 番茄工作法计时器
/// - 烹饪计时器
/// - 运动训练计时
/// - 会议倒计时
class Countdown extends TaskModel {
  /// 倒计时开始时间
  /// 
  /// 表示倒计时任务的启动时间点，用于计算剩余时间。
  /// 对于循环任务，每次重启时会更新此时间。
  DateTime startTime;
  
  /// 倒计时持续时间
  /// 
  /// 使用自定义的 Sustain 类型表示持续时间，支持天、小时、分钟等单位。
  /// 该值决定了倒计时的总时长。
  Sustain duration;
  
  /// 是否为循环倒计时
  /// 
  /// true 表示倒计时完成后会自动重启，false 表示一次性倒计时。
  /// 循环任务完成后会重置开始时间并重新开始计时。
  bool isRecurring;

  /// 倒计时任务数据库表名
  /// 
  /// 定义了在 SQLite 数据库中存储倒计时任务的表名。
  /// 该表包含 id、title、startTime、duration、isRecurring 和 isCompleted 字段。
  static const String tableName = 'countdowns';

  /// 数据库表结构定义
  /// 
  /// 定义了倒计时任务表的所有列及其数据类型。
  /// 使用 Map 结构便于动态生成 SQL 语句和维护表结构。
  static final Map<String, String> _columns = {
    'id': 'TEXT PRIMARY KEY',           // 任务唯一标识符
    'title': 'TEXT NOT NULL',           // 任务标题，不允许为空
    'startTime': 'TEXT NOT NULL',       // 开始时间，ISO8601 格式字符串
    'duration': 'INTEGER NOT NULL',     // 持续时间，以天为单位的整数值
    'isRecurring': 'INTEGER DEFAULT 0', // 是否循环，0表示false，1表示true
    'isCompleted': 'INTEGER DEFAULT 0', // 是否完成，0表示false，1表示true
  };

  /// 构造函数
  /// 
  /// 创建一个新的倒计时任务实例。
  /// 
  /// 参数:
  ///   - id: 任务唯一标识符，可选参数，不提供时自动生成
  ///   - title: 任务标题，必填参数
  ///   - startTime: 倒计时开始时间，必填参数
  ///   - duration: 倒计时持续时间，必填参数
  ///   - isRecurring: 是否为循环任务，默认为 false
  ///   - isCompleted: 是否已完成，可选参数，默认为 false
  Countdown({
    super.id,
    required super.title,
    required this.startTime,
    required this.duration,
    this.isRecurring = false,
    super.isCompleted,
  });

  /// 获取创建倒计时任务表的 SQL 语句
  /// 
  /// 使用基类提供的 sqlCreateTable 方法生成完整的 SQL 语句。
  /// 该方法会根据表名和列定义创建符合 SQLite 语法的建表语句。
  /// 
  /// 返回值：完整的 CREATE TABLE SQL 语句字符串
  /// 
  /// 示例：
  /// ```sql
  /// CREATE TABLE IF NOT EXISTS countdowns (
  ///   id TEXT PRIMARY KEY,
  ///   title TEXT NOT NULL,
  ///   startTime TEXT NOT NULL,
  ///   duration INTEGER NOT NULL,
  ///   isRecurring INTEGER DEFAULT 0,
  ///   isCompleted INTEGER DEFAULT 0
  /// )
  /// ```
  static String get sql => TaskModel.sqlCreateTable(tableName, _columns);

  /// 重启倒计时任务
  /// 
  /// 将循环倒计时任务重置为初始状态，准备下一轮计时。
  /// 该方法主要用于循环倒计时任务完成后的自动重启。
  /// 
  /// 执行操作：
  /// - 将 isCompleted 设置为 false，表示任务未完成
  /// - 将 startTime 更新为当前时间，作为新的计时起点
  /// 
  /// 注意：此方法是私有方法，仅在类内部调用
  void _restart() {
    isCompleted = false;
    startTime = DateTime.now();
  }

  /// 切换任务完成状态
  /// 
  /// 重写父类方法，添加循环任务的特殊处理逻辑。
  /// 当循环任务完成时，自动重启任务以开始下一轮计时。
  /// 
  /// 执行流程：
  /// 1. 调用父类方法切换基本完成状态
  /// 2. 检查任务是否已完成且为循环任务
  /// 3. 如果是循环任务，调用 _restart() 方法重置状态
  @override
  void changeStatus() {
    super.changeStatus();
    if (isCompleted && isRecurring) {
      _restart();
    }
  }

  /// 更新倒计时任务的详细信息
  /// 
  /// 修改倒计时任务的所有可变属性，用于编辑现有任务。
  /// 该方法直接修改对象属性，适用于任务编辑场景。
  /// 
  /// 参数:
  ///   - newTitle: 任务的新标题
  ///   - newStartTime: 任务的新开始时间
  ///   - newDuration: 任务的新持续时间
  ///   - newIsRecurring: 任务的新循环设置
  /// 
  /// 注意：此方法不会自动保存到数据库，需要调用相应的数据访问方法
  void update(String newTitle, DateTime newStartTime, Sustain newDuration,
      bool newIsRecurring) {
    title = newTitle;
    startTime = newStartTime;
    duration = newDuration;
    isRecurring = newIsRecurring;
  }

  /// 将倒计时任务对象转换为 Map
  /// 
  /// 实现数据库存储和网络传输所需的序列化功能。
  /// 将复杂类型转换为适合存储的简单类型。
  /// 
  /// 类型转换规则：
  /// - DateTime → ISO8601 格式字符串
  /// - Sustain → 以天为单位的整数值
  /// - bool → 0 或 1 的整数值
  /// 
  /// 返回值：包含所有任务属性的 Map 对象
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'duration': duration.totalDays,
      'isRecurring': isRecurring ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  /// 从 Map 创建倒计时任务对象
  /// 
  /// 实现数据库查询结果和网络传输数据的反序列化功能。
  /// 将存储的简单类型转换回原始复杂类型。
  /// 
  /// 类型转换规则：
  /// - ISO8601 格式字符串 → DateTime
  /// - 以天为单位的整数值 → Sustain
  /// - 0 或 1 的整数值 → bool
  /// 
  /// 参数:
  ///   - map: 包含任务属性的 Map 对象，通常来自数据库查询结果
  /// 
  /// 返回值：新的 Countdown 实例
  /// 
  /// 异常：如果 Map 中缺少必要字段或格式不正确，可能导致解析错误
  factory Countdown.fromMap(Map<String, dynamic> map) {
    return Countdown(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      duration: Sustain.fromDays(map['duration']),
      isRecurring: map['isRecurring'] == 1,
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
