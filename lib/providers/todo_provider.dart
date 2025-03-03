import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/todo_model.dart';
import 'package:memo/providers/task_provider.dart';

class TodoListNotifier extends BaseNotifier<Todo> {
  TodoListNotifier() : super(Todo.tableName);

  @override
  Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);

  /// 添加一个新的任务到待办事项列表中。
  ///
  /// 参数:
  ///   - title: 任务的标题。
  ///   - deadline: 任务的截止日期。
  Future<void> addTodo(String title, DateTime deadline) async {
    final newTodo = Todo(title: title, deadline: deadline);
    await addTask(newTodo);
  }

  /// 切换指定ID的任务的完成状态。
  ///
  /// 参数:
  ///   - id: 要切换完成状态的任务的ID。
  Future<void> toggleTodo(String id) async {
    await toggleTask(id);
  }

  /// 从待办事项列表中移除指定ID的任务。
  ///
  /// 参数:
  ///   - id: 要移除的任务的ID。
  Future<void> removeTodo(String id) async {
    await removeTask(id);
  }

  /// 更新指定ID的任务的标题和截止日期。
  ///
  /// 参数:
  ///   - id: 要更新的任务的ID。
  ///   - newTitle: 任务的新标题。
  ///   - newDeadline: 任务的新截止日期。
  Future<void> updateTodo(
      String id, String newTitle, DateTime newDeadline) async {
    final tmp = state.firstWhere((todo) => todo.id == id);
    tmp.update(newTitle, newDeadline);
    await super.updateTask(id, tmp);
  }
}

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});
