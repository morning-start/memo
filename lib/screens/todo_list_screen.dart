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
                    todo.isCompleted? TextDecoration.lineThrough : null,
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) {
              String title = '';
              DateTime deadline = DateTime.now().add(const Duration(days: 1));

              return AlertDialog(
                title: const Text('添加待办'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        title = value;
                      },
                      decoration: const InputDecoration(
                        hintText: '输入待办事项',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: deadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate!= null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(deadline),
                          );
                          if (pickedTime!= null) {
                            deadline = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          }
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
                    child: const Text('添加'),
                  ),
                ],
              );
            },
          );
          if (result!= null) {
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
}