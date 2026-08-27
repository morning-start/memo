import 'package:memo/models/routine_model.dart';

/// 规律事项状态枚举
enum RoutineStatus {
  /// 正常：距离下次到期还有超过预警提前量的时间
  normal,

  /// 即将到期（需准备）：已进入预警提前量窗口，需要开始准备/关注
  dueSoon,

  /// 已逾期：超过下次到期时间仍未完成
  overdue,
}

/// 可用周期模板（label 用于展示；days 用于计算）
class IntervalPreset {
  final String label;
  final int days;

  const IntervalPreset(this.label, this.days);
}

/// 常用周期模板，用于新建/编辑任务时快速选择
const List<IntervalPreset> intervalPresets = [
  IntervalPreset('每1天', 1),
  IntervalPreset('每1周', 7),
  IntervalPreset('每2周', 14),
  IntervalPreset('每1月', 30),
  IntervalPreset('每2月', 60),
  IntervalPreset('每3月', 91),
  IntervalPreset('每半年', 183),
  IntervalPreset('每1年', 365),
];

/// 可选的预警提前量，默认提前一周，可按任务自行调整
const List<IntervalPreset> warnLeadPresets = [
  IntervalPreset('提前1天', 1),
  IntervalPreset('提前3天', 3),
  IntervalPreset('提前1周', 7),
  IntervalPreset('提前2周', 14),
  IntervalPreset('提前1月', 30),
];

/// 将周期天数格式化为可读文本
String intervalLabel(int days) {
  for (final preset in intervalPresets) {
    if (preset.days == days) return preset.label;
  }
  return '每$days天';
}

/// 计算单个规律事项的状态（暂停项视为 normal，不产生提醒）
RoutineStatus routineStatus(Routine routine) {
  if (routine.isPaused) return RoutineStatus.normal;
  final next = routine.nextDue;
  final now = DateTime.now();
  if (next.isBefore(now)) return RoutineStatus.overdue;
  if (next.isBefore(now.add(Duration(days: routine.warnLeadDays)))) {
    return RoutineStatus.dueSoon;
  }
  return RoutineStatus.normal;
}

/// 距某天的剩余天数（负值表示已过去了多少天）
int daysUntil(DateTime target) {
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(target.year, target.month, target.day);
  return b.difference(a).inDays;
}

/// 生成"下次到期"的可读文案
/// 例：逾期 3 天 / 今天到期 / 明天到期 / 3 天后 / 2 周后
String nextDueLabel(Routine routine) {
  if (routine.isPaused) return '已暂停';
  final days = daysUntil(routine.nextDue);
  if (days < 0) return '已逾期 ${-days} 天';
  if (days == 0) return '今天到期';
  if (days == 1) return '明天到期';
  if (days < 7) return '$days 天后';
  final weeks = days ~/ 7;
  if (days % 7 == 0) return '$weeks 周后';
  final daysPart = days % 7;
  return '$weeks 周 $daysPart 天后';
}

/// 日期短格式，例如 08-27
String dateShort(DateTime time) {
  final mm = time.month.toString().padLeft(2, '0');
  final dd = time.day.toString().padLeft(2, '0');
  return '$mm-$dd';
}

/// 判断是否在"未来 n 天内到期或已逾期"（用于概览本周前瞻）
bool isUpcoming(Routine routine, {int windowDays = 7}) {
  if (routine.isPaused) return false;
  final days = daysUntil(routine.nextDue);
  return days <= windowDays;
}

/// 格式化预警提前量，例如：提前 1 周 / 提前 1 个月。
/// 命中模板则直接复用模板文案，否则回退为"提前 X 天"。
String remindLeadLabel(int leadDays) {
  for (final preset in warnLeadPresets) {
    if (preset.days == leadDays) return preset.label;
  }
  return '提前$leadDays天';
}