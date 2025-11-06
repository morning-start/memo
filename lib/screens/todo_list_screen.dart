import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:memo/providers/todo_provider.dart';
import 'package:memo/widgets/info_button.dart';
import 'package:memo/widgets/list_view.dart';

/// 待办事项列表页面
///
/// 显示和管理待办事项的用户界面，支持创建、编辑、删除和切换待办事项状态。
/// 该页面使用 Riverpod 进行状态管理，通过 ConsumerWidget 响应状态变化。
///
/// 功能特点：
/// - 展示所有待办事项列表，包括截止时间显示
/// - 支持添加新待办事项
/// - 支持编辑现有待办事项的标题和截止时间
/// - 支持切换待办事项完成状态和删除任务
/// - 提供直观的日期时间选择器
///
/// 状态管理：
/// - 使用 todoListProvider 获取待办事项列表数据
/// - 使用 todoListProvider.notifier 执行状态变更操作
class TodoListScreen extends ConsumerWidget {
  /// 构造函数
  /// 
  /// 创建一个待办事项列表页面实例。
  const TodoListScreen({super.key});

  /// 构建页面UI
  /// 
  /// 根据当前状态构建待办事项列表页面的用户界面。
  /// 
  /// 参数：
  ///   - context: 构建上下文，用于访问主题、导航等
  ///   - ref: WidgetRef 引用，用于访问 Riverpod 状态
  /// 
  /// 返回值：构建好的页面 Widget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听待办事项列表状态变化
    final todos = ref.watch(todoListProvider);
    // 获取待办事项状态管理器，用于执行状态变更操作
    final todoListNotifier = ref.read(todoListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('待办列表'),
      ),
      body: TaskListView(
        items: todos,
        // 构建每个待办事项的副标题，显示截止时间
        subtitleBuilder: (todo) {
          return Text(
            DateFormat('yyyy-MM-dd HH:mm').format(todo.deadline),
          );
        },
        // 编辑待办事项的回调函数
        editFunc: (todo) async {
          // 显示对话框以修改待办事项
          final result =
              await _showTodoDialog(context, todo.title, todo.deadline);
          if (result != null) {
            // 调用状态管理器更新待办事项
            todoListNotifier.updateTodo(
              todo.id,
              result['title'] as String,
              result['deadline'] as DateTime,
            );
          }
        },
        // 切换待办事项完成状态的回调函数
        toggleFunc: (id) {
          todoListNotifier.toggleTodo(id);
        },
        // 删除待办事项的回调函数
        delFunc: (id) {
          todoListNotifier.removeTodo(id);
        },
      ),
      // 添加新待办事项的浮动操作按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 显示对话框以添加新的待办事项
          final result = await _showTodoDialog(
              context, '', DateTime.now().add(const Duration(days: 1)));
          if (result != null) {
            // 调用状态管理器添加新的待办事项
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

  /// 显示待办事项编辑对话框
  /// 
  /// 弹出一个对话框，用于添加新待办事项或编辑现有待办事项。
  /// 对话框包含标题输入和截止时间选择功能。
  /// 
  /// 参数：
  ///   - context: 构建上下文
  ///   - initialTitle: 初始标题，空字符串表示新建
  ///   - initialDeadline: 初始截止时间
  /// 
  /// 返回值：包含用户输入数据的 Map，如果用户取消则返回 null
  Future<Map<String, dynamic>?> _showTodoDialog(BuildContext context,
      String initialTitle, DateTime initialDeadline) async {
    // 初始化控制器和变量
    final titleController = TextEditingController(text: initialTitle);
    DateTime deadline = initialDeadline;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(initialTitle.isEmpty ? '添加待办' : '修改待办'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题输入框
                  TextField(
                    controller: titleController,
                    onChanged: (value) {
                      // 不需要额外操作，controller 会自动更新文本
                    },
                    decoration: InputDecoration(
                      hintText: '输入待办事项',
                      labelText: '标题',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 截止时间选择按钮
                  InfoButton(
                      onPressed: () async {
                        // 显示日期和时间选择器
                        final pickedDateTime =
                            await _pickDateTime(context, deadline);
                        if (pickedDateTime != null) {
                          setState(() {
                            deadline = pickedDateTime;
                          });
                        }
                      },
                      label: '选择截止时间',
                      feedback:
                          '${deadline.year}-${deadline.month}-${deadline.day}  ${deadline.hour}:${deadline.minute}'),
                ],
              ),
              actions: [
                // 取消按钮
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                // 确认按钮
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

  /// 显示日期时间选择器
  /// 
  /// 弹出系统日期选择器和时间选择器，允许用户选择日期和时间。
  /// 
  /// 参数：
  ///   - context: 构建上下文
  ///   - initialDateTime: 初始日期时间
  /// 
  /// 返回值：用户选择的日期时间，如果用户取消则返回 null
  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime initialDateTime) async {
    // 显示日期选择器
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(), // 最早可选择当前日期
      lastDate: DateTime(2100), // 最晚可选择2100年
    );
    // 如果用户选择了日期且上下文仍然有效
    if (pickedDate != null && context.mounted) { // 检查context是否仍然挂载
      // 显示时间选择器
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );
      // 如果用户选择了时间且上下文仍然有效
      if (pickedTime != null && context.mounted) { // 再次检查context是否仍然挂载
        // 组合日期和时间
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