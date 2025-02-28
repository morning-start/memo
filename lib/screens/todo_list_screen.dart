import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final todoListNotifier = ref.read(todoListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('待办列表'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(todo.deadline),
            ),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                todoListNotifier.toggleTodo(todo.id);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                todoListNotifier.removeTodo(todo.id);
              },
            ),
            onTap: () async {
              // 显示对话框以修改待办事项
              final result = await _showTodoDialog(context, todo.title, todo.deadline);
              if (result != null) {
                todoListNotifier.updateTodo(
                  todo.id,
                  result['title'] as String,
                  result['deadline'] as DateTime,
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 显示对话框以添加新的待办事项
          final result = await _showTodoDialog(context, '', DateTime.now().add(const Duration(days: 1)));
          if (result != null) {
            todoListNotifier.addTodo(
              result['title'] as String,
              result['deadline'] as DateTime,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showTodoDialog(BuildContext context, String initialTitle, DateTime initialDeadline) async {
    String title = initialTitle;
    DateTime deadline = initialDeadline;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialTitle.isEmpty ? '添加待办' : '修改待办'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: initialTitle),
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(
                  hintText: '输入待办事项',
                  labelText: '标题',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // 显示日期和时间选择器
                  final pickedDateTime = await _pickDateTime(context, deadline);
                  if (pickedDateTime != null) {
                    deadline = pickedDateTime;
                  }
                },
                child: const Text('选择截止时间'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'title': title,
                  'deadline': deadline,
                });
              },
              child: Text(initialTitle.isEmpty ? '添加' : '保存'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDateTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }
}
