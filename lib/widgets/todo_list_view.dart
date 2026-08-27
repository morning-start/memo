import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:memo/models/todo_model.dart';
import 'package:memo/providers/todo_provider.dart';
import 'package:memo/utils/app_theme.dart';
import 'package:memo/widgets/info_button.dart';
import 'package:memo/widgets/list_view.dart';

/// 一次性待办列表
///
/// 展示"带截止日期、做完即止"的一次性任务，作为周期任务的补充。
/// 该组件仅渲染列表本体（不包含 AppBar 与 FAB），便于嵌入"任务"页的
/// 分段 Tab 中，FAB 由外层管理。
class TodoListView extends ConsumerWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final todos = ref.watch(todoListProvider);
    final notifier = ref.read(todoListProvider.notifier);

    if (todos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.checklist_rounded,
                    size: 40, color: cs.primary.withOpacity(0.5)),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('没有待办事项',
                  style: AppTypography.titleMedium(isDark)),
              const SizedBox(height: AppSpacing.sm),
              Text('日常一次性任务、一次性截止事件可以放在这里',
                  style: AppTypography.bodyMedium(isDark)),
            ],
          ),
        ),
      );
    }

    return TaskListView(
      items: todos,
      subtitleBuilder: (todo) {
        return Text(DateFormat('yyyy-MM-dd HH:mm').format(todo.deadline));
      },
      editFunc: (todo) async {
        final result = await showTodoDialog(context, ref, editing: todo);
        if (result != null) {
          notifier.updateTodo(
            todo.id,
            result['title'] as String,
            result['deadline'] as DateTime,
          );
        }
      },
      toggleFunc: (id) => notifier.toggleTodo(id),
      delFunc: (id) => notifier.removeTodo(id),
    );
  }
}

/// 弹出"新建/编辑一次性待办"对话框。
/// 非编辑状态下需自行处理返回值后在调用方 addTodo。
Future<Map<String, dynamic>?> showTodoDialog(
  BuildContext context,
  WidgetRef ref, {
  Todo? editing,
}) {
  final initialTitle = editing?.title ?? '';
  final initialDeadline =
      editing?.deadline ?? DateTime.now().add(const Duration(days: 1));
  final titleController = TextEditingController(text: initialTitle);
  DateTime deadline = initialDeadline;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(initialTitle.isEmpty ? '新建待办' : '编辑待办'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '输入一次性待办',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InfoButton(
                  onPressed: () async {
                    final picked = await _pickDateTime(context, deadline);
                    if (picked != null) setState(() => deadline = picked);
                  },
                  label: '选择截止时间',
                  feedback:
                      '${deadline.year}-${deadline.month}-${deadline.day}  ${deadline.hour}:${deadline.minute}',
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'deadline': deadline,
                  });
                },
                child: Text(initialTitle.isEmpty ? '添加' : '保存'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// 日期 + 时间选择器
Future<DateTime?> _pickDateTime(
    BuildContext context, DateTime initialDateTime) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null && context.mounted) {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (pickedTime != null && context.mounted) {
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
