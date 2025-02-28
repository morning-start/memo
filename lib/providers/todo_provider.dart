import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  /// 添加一个新的任务到待办事项列表中。
  /// 
  /// 参数:
  ///   - [title]: 任务的标题。
  ///   - [deadline]: 任务的截止日期。
  void addTodo(String title, DateTime deadline) {
    final newTodo = Todo(title: title, deadline: deadline);
    state = [...state, newTodo];
  }

  /// 切换指定ID的任务的完成状态。
  /// 
  /// 参数:
  ///   - [id]: 要切换完成状态的任务的ID。
  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            title: todo.title,
            deadline: todo.deadline,
            isCompleted: !todo.isCompleted,
          )
        else
          todo
    ];
  }

  /// 从待办事项列表中移除指定ID的任务。
  /// 
  /// 参数:
  ///   - [id]: 要移除的任务的ID。
  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  /// 更新指定ID的任务的标题和截止日期。
  /// 
  /// 参数:
  ///   - [id]: 要更新的任务的ID。
  ///   - [newTitle]: 任务的新标题。
  ///   - [newDeadline]: 任务的新截止日期。
  void updateTodo(String id, String newTitle, DateTime newDeadline) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            title: newTitle,
            deadline: newDeadline,
            isCompleted: todo.isCompleted,
          )
        else
          todo
    ];
  }

  /// 清除待办事项列表中的所有任务。
  void clearTodos() {
    state = [];
  }
}

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});
