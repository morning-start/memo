import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/task_model.dart';
import 'package:memo/utils/db_helper.dart';

abstract class TaskNotifier<T extends TaskModel> extends StateNotifier<List<T>> {
  late DatabaseHelper _db;
  final String tableName;

  TaskNotifier(this.tableName) : super([]) {
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

  Future<void> removeTask(String id) async {
    await _db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    state = state.where((task) => task.id != id).toList();
  }

  Future<void> toggleTask(String id) async {
    final tmp = state.firstWhere((task) => task.id == id);
    tmp.changeStatus();
    await updateTask(id, tmp);
  }

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

  /// 在数据同步完成并重新打开数据库后，刷新任务列表
  Future<void> refreshTasksAfterSync() async {
    await _db.reopenDatabase(); // 重新打开数据库
    await _loadTasks(); // 重新加载数据
  }
}