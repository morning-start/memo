import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/countdown_model.dart';
import 'package:memo/providers/task_provider.dart';
import 'package:memo/utils/sustain.dart';

/// 倒计时任务状态管理器
///
/// 继承自 TaskNotifier 基类，专门处理倒计时任务的业务逻辑。
/// 提供倒计时任务的增删改查功能，包括添加新倒计时、切换完成状态、
/// 更新倒计时信息和删除倒计时等操作。
///
/// 设计特点：
/// - 封装倒计时任务特有的业务逻辑
/// - 复用 TaskNotifier 提供的通用数据库操作
/// - 支持循环倒计时任务的特殊处理
/// - 通过 Riverpod 实现响应式状态管理
class CountdownNotifier extends TaskNotifier<Countdown> {
  /// 构造函数
  ///
  /// 调用父类构造函数，传入倒计时表名，初始化数据库连接和状态。
  CountdownNotifier() : super(Countdown.tableName);

  /// 添加一个新的倒计时任务
  ///
  /// 创建新的 Countdown 对象并保存到数据库，同时更新应用状态。
  /// 这是用户创建新倒计时任务的主要入口点。
  /// 
  /// 参数:
  ///   - title: 倒计时任务的标题
  ///   - startTime: 倒计时任务的开始时间
  ///   - duration: 倒计时任务的持续时间
  ///   - isRecurring: 倒计时任务是否为循环任务
  Future<void> addCountdown(String title, DateTime startTime, Sustain duration,
      bool isRecurring) async {
    final countdown = Countdown(
      title: title,
      startTime: startTime,
      duration: duration,
      isRecurring: isRecurring,
    );
    await super.addTask(countdown);
  }

  /// 将数据库记录映射为 Countdown 对象
  ///
  /// 实现父类抽象方法，将数据库查询结果转换为 Countdown 模型对象。
  /// 这是类型安全的关键，确保状态列表中只包含 Countdown 对象。
  /// 
  /// 参数：
  ///   - map: 数据库查询结果的字典数据
  ///
  /// 返回：转换后的 Countdown 对象实例
  @override
  Countdown fromMap(Map<String, dynamic> map) => Countdown.fromMap(map);

  /// 切换指定倒计时任务的完成状态
  ///
  /// 查找指定 ID 的倒计时任务，切换其完成状态（完成/未完成），
  /// 并将变更保存到数据库。状态变更会自动触发 UI 更新。
  ///
  /// 对于循环倒计时任务，完成状态重置后会自动重新开始计时。
  /// 
  /// 参数:
  ///   - id: 要切换完成状态的倒计时任务 ID
  Future<void> toggleCountdown(String id) async {
    await toggleTask(id);
  }

  /// 删除指定的倒计时任务
  ///
  /// 从数据库和状态列表中移除指定 ID 的倒计时任务。
  /// 删除操作是不可逆的，执行前应确认用户意图。
  /// 
  /// 参数:
  ///   - id: 要删除的倒计时任务 ID
  Future<void> removeCountdown(String id) async {
    await super.removeTask(id);
  }

  /// 更新指定倒计时任务的信息
  ///
  /// 修改倒计时任务的标题、开始时间、持续时间和循环设置，
  /// 并将变更保存到数据库。使用 copyWith 模式确保不可变性，
  /// 符合函数式编程原则。
  /// 
  /// 参数:
  ///   - id: 要更新的倒计时任务 ID
  ///   - newTitle: 倒计时任务的新标题
  ///   - newStartTime: 倒计时任务的新开始时间
  ///   - newDuration: 倒计时任务的新持续时间
  ///   - newIsRecurring: 倒计时任务的新循环设置
  Future<void> updateCountdown(String id, String newTitle,
      DateTime newStartTime, Sustain newDuration, bool newIsRecurring) async {
    final tmp = state.firstWhere((countdown) => countdown.id == id);
    tmp.update(newTitle, newStartTime, newDuration, newIsRecurring);
    await super.updateTask(id, tmp);
  }
}

/// 倒计时任务状态提供者
/// 
/// 使用 StateNotifierProvider 创建全局可访问的倒计时任务状态。
/// UI 组件通过此提供者监听倒计时任务列表变化，实现响应式更新。
/// 
/// 返回值：包含 CountdownNotifier 实例和 List<Countdown> 状态的提供者
final countdownProvider =
    StateNotifierProvider<CountdownNotifier, List<Countdown>>(
  (ref) => CountdownNotifier(),
);