import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/base_model.dart';
import 'package:memo/utils/db_helper.dart';

abstract class BaseNotifier<T extends BaseModel>
    extends StateNotifier<List<T>> {
  late DatabaseHelper _db;
  final String tableName;

  BaseNotifier(this.tableName) : super([]) {
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _db = DatabaseHelper();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final List<Map<String, dynamic>> maps = await _db.query(tableName);
    state = List.generate(maps.length, (i) {
      return fromMap(maps[i]);
    });
  }

  T fromMap(Map<String, dynamic> map) => throw UnimplementedError();

  Future<void> addTask(T task) async {
    await _db.insert(
      tableName,
      task.toMap(),
    );
    state = [...state, task];
  }

  /// 根据ID移除一个倒计时任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeTask(String id) async {
    await _db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    state = state.where((task) => task.id != id).toList();
  }

  /// 根据ID切换一个倒计时任务的状态。
  ///
  /// 如果任务已完成且是循环任务，则会重新开始。
  ///
  /// 参数:
  ///   - id: 要切换状态的任务的ID。
  Future<void> toggleTask(String id) async {
    final tmp = state.firstWhere((task) => task.id == id);
    tmp.changeStatus();
    await updateTask(id, tmp);
  }

  /// 根据ID更新一个倒计时任务的详细信息。
  ///
  /// 参数:
  ///   - id: 要更新的任务的ID。
  ///   - task: 要更新的任务对象。
  Future<void> updateTask(String id, T task) async {
    await _db.update(
      tableName,
      task.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );
    state = [
      for (final task in state)
        if (task.id == id) task else task
    ];
  }

  Future<void> clearTasks() async {
    await _db.delete(tableName);
    state = [];
  }
}
