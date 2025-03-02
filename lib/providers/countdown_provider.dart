import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/countdown_model.dart';
import 'package:memo/providers/base_provider.dart';

class CountdownNotifier extends BaseNotifier<Countdown> {
  CountdownNotifier() : super(Countdown.tableName);

  /// 添加一个新的倒计时任务。
  ///
  /// 参数:
  ///   - task: 要添加的倒计时任务对象。
  Future<void> addCutdown(Countdown task) async {
    await super.addTask(task);
  }
  
  /// 切换指定ID的任务的完成状态。
  ///
  /// 参数:
  ///   - id: 要切换完成状态的任务的ID。
  Future<void> toggleCutdown(String id) async {
    await toggleTask(id);
  }

  /// 根据ID移除一个倒计时任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeCutdown(String id) async {
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
  Future<void> updateCutdown(String id, String newTitle, DateTime newStartTime,
      Duration newDuration, bool newIsRecurring) async {
    final updatedTask = state.firstWhere((task) => task.id == id);
    updatedTask.update(newTitle, newStartTime, newDuration, newIsRecurring);
    await super.updateTask(id, updatedTask);
  }
}

final countdownProvider =
    StateNotifierProvider<CountdownNotifier, List<Countdown>>(
  (ref) => CountdownNotifier(),
);
