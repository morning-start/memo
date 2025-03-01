import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/tools/db_seeder.dart';
import '../models/countdown_model.dart';
import 'package:sqflite/sqflite.dart';

class CountdownNotifier extends StateNotifier<List<Countdown>> {
  late Database _db;

  CountdownNotifier() : super([]) {
    _initializeDatabase();
  }

  /// 初始化数据库并加载任务。
  ///
  /// 此方法会在初始化时被调用，用于设置数据库连接并加载已有的倒计时任务。
  Future<void> _initializeDatabase() async {
    _db = await initializeDatabase(Countdown.toSqlCreateTable);

    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final List<Map<String, dynamic>> maps =
        await _db.query(Countdown.tableName);

    state = List.generate(maps.length, (i) {
      return Countdown.fromMap(maps[i]);
    });
  }

  /// 添加一个新的倒计时任务。
  ///
  /// 参数:
  ///   - task: 要添加的倒计时任务对象。
  Future<void> addTask(Countdown task) async {
    await _db.insert(
      Countdown.tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    state = [...state, task];
  }

  /// 根据ID移除一个倒计时任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeTask(String id) async {
    await _db.delete(
      Countdown.tableName,
      where: 'id = ?',
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
    final updatedTask = state.firstWhere((task) => task.id == id);
    updatedTask.changeStatus();
    if (updatedTask.isCompleted && updatedTask.isRecurring) {
      updatedTask.restart();
    }
    await _db.update(
      Countdown.tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }

  /// 根据ID更新一个倒计时任务的详细信息。
  ///
  /// 参数:
  ///   - id: 要更新的任务的ID。
  ///   - newTitle: 新的任务标题。
  ///   - newStartTime: 新的任务开始时间。
  ///   - newDuration: 新的任务持续时间。
  ///   - newIsRecurring: 新的任务是否为循环任务。
  Future<void> updateTask(String id, String newTitle, DateTime newStartTime,
      Duration newDuration, bool newIsRecurring) async {
    final updatedTask = state.firstWhere((task) => task.id == id);
    updatedTask.update(newTitle, newStartTime, newDuration, newIsRecurring);
    await _db.update(
      Countdown.tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }
}

final countdownProvider =
    StateNotifierProvider<CountdownNotifier, List<Countdown>>(
  (ref) => CountdownNotifier(),
);
