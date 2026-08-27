import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/routine_model.dart';
import 'package:memo/utils/db_helper.dart';

/// 规律事项状态管理
///
/// 负责规律事项（长期/周期任务）的增删改查与持久化。
/// 核心机制是"自动重置"：勾选完成时只更新"上次完成时间"，下次到期
/// 由模型自动推算为`上次完成时间 + 周期`，用户无需记忆下次时间点。
class RoutineNotifier extends StateNotifier<List<Routine>> {
  late final DatabaseHelper _db;

  RoutineNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _db = DatabaseHelper();
    await reload();
  }

  /// 从数据库加载全部规律事项
  Future<void> reload() async {
    await _db.reopenDatabase();
    final maps = await _db.query(Routine.tableName);
    state = [for (final map in maps) Routine.fromMap(map)];
  }

  /// 新增规律事项
  Future<void> addRoutine({
    required String title,
    String? groupId,
    required int intervalDays,
    int warnLeadDays = 7,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final routine = Routine(
      title: trimmed,
      groupId: groupId,
      intervalDays: intervalDays,
      warnLeadDays: warnLeadDays,
    );
    await _db.insert(Routine.tableName, routine.toMap());
    state = [...state, routine];
  }

  /// 更新规律事项的编辑字段
  Future<void> updateRoutine({
    required String id,
    String? title,
    String? groupId,
    int? intervalDays,
    int? warnLeadDays,
  }) async {
    final routine = state.firstWhere((r) => r.id == id);
    if (title != null && title.trim().isNotEmpty) routine.title = title.trim();
    if (groupId != null) routine.groupId = groupId.isEmpty ? null : groupId;
    if (intervalDays != null && intervalDays > 0) {
      routine.intervalDays = intervalDays;
    }
    if (warnLeadDays != null) routine.warnLeadDays = warnLeadDays;
    await _save(routine);
  }

  /// 标记完成：把"上次完成时间"更新为现在，下次到期自动向后滚动。
  /// 这是"减轻记忆负担"的核心动作，用户只需点一下，无需记下一次何时。
  Future<void> markCompleted(String id) async {
    final routine = state.firstWhere((r) => r.id == id);
    routine.lastCompletedAt = DateTime.now();
    await _save(routine);
  }

  /// 暂停 / 恢复
  Future<void> togglePause(String id) async {
    final routine = state.firstWhere((r) => r.id == id);
    routine.isPaused = !routine.isPaused;
    await _save(routine);
  }

  /// 删除规律事项
  Future<void> removeRoutine(String id) async {
    await _db.delete(Routine.tableName, where: 'id = ?', whereArgs: [id]);
    state = state.where((r) => r.id != id).toList();
  }

  /// 同步后刷新（下载数据库覆盖本地后调用）
  Future<void> refreshTasksAfterSync() async {
    await reload();
  }

  Future<void> _save(Routine routine) async {
    state = [...state];
    await _db.update(
      Routine.tableName,
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }
}

/// 规律事项数据 Provider
final routinesProvider = StateNotifierProvider<RoutineNotifier, List<Routine>>(
  (ref) => RoutineNotifier(),
);