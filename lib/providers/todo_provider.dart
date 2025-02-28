import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  void addTodo(String title, DateTime deadline) {
    final newTodo = Todo(title: title, deadline: deadline);
    state = [...state, newTodo];
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            title: todo.title,
            deadline: todo.deadline,
            isCompleted:!todo.isCompleted,
          )
        else
          todo
    ];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id!= id).toList();
  }
}

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});