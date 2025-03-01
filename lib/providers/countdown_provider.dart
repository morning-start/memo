import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/tools/db_seeder.dart';
import '../models/countdown_model.dart';
import 'package:sqflite/sqflite.dart';

class CountdownNotifier extends StateNotifier<List<Countdown>> {
  late Database _db;

  CountdownNotifier() : super([]) {
    _initializeDatabase();
  }

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

  Future<void> addTask(Countdown task) async {
    await _db.insert(
      Countdown.tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    state = [...state, task];
  }

  Future<void> removeTask(String id) async {
    await _db.delete(
      Countdown.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    state = state.where((task) => task.id != id).toList();
  }

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
