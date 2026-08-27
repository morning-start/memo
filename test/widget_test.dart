import 'package:flutter_test/flutter_test.dart';

import 'package:memo/models/routine_model.dart';
import 'package:memo/utils/routine_logic.dart';

void main() {
  // 常规规律事项测试

  test('nextDue：从"上次完成时间 + 周期"自动推导（自动重置核心）', () {
    final created = DateTime(2026, 1, 1, 8);
    final routine = Routine(
      title: '更换净水器滤芯',
      intervalDays: 30,
      createdAt: created,
    );

    // 从未完成时，以创建时间作为锚点
    expect(routine.nextDue, DateTime(2026, 1, 31, 8));

    // 完成后，以下次到期为新的"上次完成"，下一次顺延一个周期
    routine.lastCompletedAt = DateTime(2026, 1, 31, 8);
    expect(routine.nextDue, DateTime(2026, 3, 2, 8));
  });

  test('间隔标签：常见的周期映射为友好文案', () {
    expect(intervalLabel(7), '每1周');
    expect(intervalLabel(30), '每1月');
    expect(intervalLabel(91), '每3月');
    expect(intervalLabel(365), '每1年');
    expect(intervalLabel(90), '每90天');
  });

  test('状态：暂停的任务不进入即将到期 / 逾期', () {
    final routine = Routine(title: 'x', intervalDays: 30, createdAt: DateTime.now());
    routine.lastCompletedAt = DateTime.now().subtract(const Duration(days: 40)); // 已过期
    routine.isPaused = true;
    expect(routineStatus(routine), RoutineStatus.normal);
  });
}