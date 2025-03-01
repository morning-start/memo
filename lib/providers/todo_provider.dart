import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import 'package:sqflite/sqflite.dart';
import '../tools/db_seeder.dart';

class TodoListNotifier extends StateNotifier<List<Todo>> {
  late Database _db;

  TodoListNotifier() : super([]) {
    _initializeDatabase();
    _loadTodos();
  }

  Future<void> _initializeDatabase() async {
    _db = await openTable(Todo.sql);
    await _loadTodos();
  }

  Future<void> _loadTodos() async {
    final List<Map<String, dynamic>> maps = await _db.query(Todo.tableName);
    state = List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  /// 添加一个新的任务到待办事项列表中。
  ///
  /// 参数:
  ///   - title: 任务的标题。
  ///   - deadline: 任务的截止日期。
  Future<void> addTodo(String title, DateTime deadline) async {
    final newTodo = Todo(title: title, deadline: deadline);
    await _db.insert(
      Todo.tableName,
      newTodo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state = [...state, newTodo];
  }

  /// 切换指定ID的任务的完成状态。
  ///
  /// 参数:
  ///   - id: 要切换完成状态的任务的ID。
  Future<void> toggleTodo(String id) async {
    final updatedTodo = state.firstWhere((todo) => todo.id == id);
    updatedTodo.changeStatus();

    await _db.update(
      Todo.tableName,
      updatedTodo.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );
    state = [
      for (final todo in state)
        if (todo.id == id) updatedTodo else todo
    ];
  }

  /// 从待办事项列表中移除指定ID的任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeTodo(String id) async {
    await _db.delete(
      Todo.tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    state = state.where((todo) => todo.id != id).toList();
  }

  /// 更新指定ID的任务的标题和截止日期。
  ///
  /// 参数:
  ///   - id: 要更新的任务的ID。
  ///   - newTitle: 任务的新标题。
  ///   - newDeadline: 任务的新截止日期。
  Future<void> updateTodo(
      String id, String newTitle, DateTime newDeadline) async {
    final updatedTodo = state.firstWhere((todo) => todo.id == id);
    updatedTodo.update(newTitle, newDeadline);
    await _db.update(
      Todo.tableName,
      updatedTodo.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );
    state = [
      for (final todo in state)
        if (todo.id == id) updatedTodo else todo
    ];
  }

  /// 清除待办事项列表中的所有任务。
  Future<void> clearTodos() async {
    await _db.delete(Todo.tableName);
    state = [];
  }
}

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});
