import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoListNotifier extends StateNotifier<List<Todo>> {
  late Database _database;

  TodoListNotifier() : super([]) {
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'todos_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, deadline TEXT, isCompleted INTEGER)',
        );
      },
      version: 1,
    );
    await loadTodos();
  }

  void addTodo(String title, DateTime deadline) async {
    final newTodo = Todo(title: title, deadline: deadline);
    await _database.insert(
      'todos',
      newTodo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state = [...state, newTodo];
  }

  void toggleTodo(String id) async {
    final updatedTodo = state.firstWhere((todo) => todo.id == id).copyWith(isCompleted: !state.firstWhere((todo) => todo.id == id).isCompleted);
    await _database.update(
      'todos',
      updatedTodo.toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );
    state = [
      for (final todo in state)
        if (todo.id == id) updatedTodo else todo
    ];
  }

  void removeTodo(String id) async {
    await _database.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    state = state.where((todo) => todo.id != id).toList();
  }

  // 加载待办事项列表
  Future<void> loadTodos() async {
    final List<Map<String, dynamic>> maps = await _database.query('todos');
    state = List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        deadline: DateTime.parse(maps[i]['deadline']),
        isCompleted: maps[i]['isCompleted'] == 1,
      );
    });
  }


}

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>(
  (ref) {
    final notifier = TodoListNotifier();
    return notifier;
  },
);
