import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/countdown_model.dart';
import 'package:memo/providers/base_provider.dart';

class CountdownNotifier extends BaseNotifier<Countdown> {
  CountdownNotifier() : super(Countdown.tableName);

  /// 添加一个新的倒计时任务。
  ///
  /// 参数:
  ///  - title: 任务的标题。
  ///   - startTime: 任务的开始时间。
  ///   - duration: 任务的持续时间。
  ///   - isRecurring: 任务是否为循环任务。
  Future<void> addCountdown(String title, DateTime startTime, Duration duration,
      bool isRecurring) async {
    final countdown = Countdown(
      title: title,
      startTime: startTime,
      duration: duration,
      isRecurring: isRecurring,
    );
    await super.addTask(countdown);
  }

  @override
  Countdown fromMap(Map<String, dynamic> map) => Countdown.fromMap(map);

  /// 切换指定ID的任务的完成状态。
  ///
  /// 参数:
  ///   - id: 要切换完成状态的任务的ID。
  Future<void> toggleCountdown(String id) async {
    await toggleTask(id);
  }

  /// 根据ID移除一个倒计时任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeCountdown(String id) async {
    await super.removeTask(id);
  }

  /// 根据ID更新一个倒计时任务的详细信息。
  ///
  /// 参数:
  ///   - id: 要更新的任务的ID。
  ///   - newTitle: 新的任务标题。
  ///   - newStartTime: 新的任务开始时间。
  ///   - newDuration: 新的任务持续时间。
  ///   - newIsRecurring: 新的任务是否为循环任务。
  Future<void> updateCountdown(String id, String newTitle,
      DateTime newStartTime, Duration newDuration, bool newIsRecurring) async {
    final tmp = state.firstWhere((countdown) => countdown.id == id);
    tmp.update(newTitle, newStartTime, newDuration, newIsRecurring);
    await super.updateTask(id, tmp);
  }
}

final countdownProvider =
    StateNotifierProvider<CountdownNotifier, List<Countdown>>(
  (ref) => CountdownNotifier(),
);
