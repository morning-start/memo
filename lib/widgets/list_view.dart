import 'package:flutter/material.dart';

import 'package:memo/models/task_model.dart';

class TaskListView<T extends TaskModel> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T task)? subtitleBuilder;
  final void Function(T task) editFunc;
  final void Function(String id) toggleFunc;
  final void Function(String id) delFunc;

  const TaskListView({
    super.key,
    required this.items,
    this.subtitleBuilder,
    required this.editFunc,
    required this.toggleFunc, // 增加toggleFunc参数
    required this.delFunc, // 增加delFunc参数
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item.title,
            style: TextStyle(
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: subtitleBuilder != null ? subtitleBuilder!(item) : null,
          leading: Checkbox(
            value: item.isCompleted,
            onChanged: (value) {
              toggleFunc(item.id); // 调用toggleFunc
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              delFunc(item.id); // 调用delFunc
            },
          ),
          onTap: () => editFunc(item),
        );
      },
    );
  }
}
