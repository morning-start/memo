import 'package:flutter/material.dart';

import 'package:memo/models/task_model.dart';

/// 任务列表视图组件
/// 
/// 用于显示任务列表的自定义组件，支持泛型约束，可显示任何继承自TaskModel的任务类型。
/// 该组件提供完整的任务管理功能，包括任务状态切换、编辑和删除操作。
/// 
/// 功能特点：
/// - 支持泛型约束，可处理多种任务类型
/// - 自定义子标题构建器，灵活显示任务详情
/// - 任务完成状态可视化（删除线效果）
/// - 复选框快速切换任务状态
/// - 内置编辑和删除操作按钮
/// - 响应式列表视图，支持大量数据高效渲染
/// 
/// 使用示例：
/// ```dart
/// TaskListView<TodoModel>(
///   items: todoList,
///   subtitleBuilder: (task) => Text(task.description),
///   editFunc: (task) => navigateToEdit(task),
///   toggleFunc: (id) => toggleTaskStatus(id),
///   delFunc: (id) => deleteTask(id),
/// )
/// ```
/// 
/// 注意事项：
/// - 确保items列表中的所有元素都继承自TaskModel
/// - toggleFunc和delFunc参数为必填，必须提供有效的回调函数
/// - subtitleBuilder为可选参数，不提供则不显示子标题
/// - 列表项点击会触发编辑功能，确保editFunc已正确实现
class TaskListView<T extends TaskModel> extends StatelessWidget {
  /// 任务项列表
  /// 
  /// 要显示的任务对象列表，所有元素必须继承自TaskModel基类。
  final List<T> items;
  
  /// 子标题构建器
  /// 
  /// 可选的回调函数，用于构建每个任务项的子标题内容。
  /// 如果为null，则不显示子标题。
  final Widget Function(T task)? subtitleBuilder;
  
  /// 编辑回调函数
  /// 
  /// 当用户点击任务项时调用的函数，用于处理任务编辑操作。
  final void Function(T task) editFunc;
  
  /// 状态切换回调函数
  /// 
  /// 当用户点击复选框时调用的函数，用于切换任务的完成状态。
  final void Function(String id) toggleFunc;
  
  /// 删除回调函数
  /// 
  /// 当用户点击删除按钮时调用的函数，用于删除指定任务。
  final void Function(String id) delFunc;

  /// 构造函数
  /// 
  /// 创建一个任务列表视图组件实例。
  /// 
  /// [key] 用于组件标识的可选键
  /// [items] 任务项列表，必填参数
  /// [subtitleBuilder] 子标题构建器，可选参数
  /// [editFunc] 编辑回调函数，必填参数
  /// [toggleFunc] 状态切换回调函数，必填参数
  /// [delFunc] 删除回调函数，必填参数
  const TaskListView({
    super.key,
    required this.items,
    this.subtitleBuilder,
    required this.editFunc,
    required this.toggleFunc, // 增加toggleFunc参数
    required this.delFunc, // 增加delFunc参数
  });

  /// 构建组件UI
  /// 
  /// 构建任务列表的用户界面，使用ListView.builder实现高效渲染。
  /// 每个任务项包含标题、可选子标题、状态复选框和删除按钮。
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回配置好的ListView组件
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 设置列表项数量
      itemCount: items.length,
      // 构建列表项的回调函数
      itemBuilder: (context, index) {
        // 获取当前任务项
        final item = items[index];
        return ListTile(
          // 任务标题，根据完成状态添加删除线效果
          title: Text(
            item.title,
            style: TextStyle(
              // 如果任务已完成，添加删除线效果
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          // 可选的子标题，由subtitleBuilder构建
          subtitle: subtitleBuilder != null ? subtitleBuilder!(item) : null,
          // 左侧复选框，用于切换任务状态
          leading: Checkbox(
            // 复选框状态与任务完成状态同步
            value: item.isCompleted,
            // 复选框状态变化时的回调
            onChanged: (value) {
              // 调用toggleFunc切换任务状态
              toggleFunc(item.id);
            },
          ),
          // 右侧删除按钮
          trailing: IconButton(
            // 删除图标
            icon: const Icon(Icons.delete),
            // 点击删除按钮时的回调
            onPressed: () {
              // 调用delFunc删除任务
              delFunc(item.id);
            },
          ),
          // 点击任务项时的回调，触发编辑功能
          onTap: () => editFunc(item),
        );
      },
    );
  }
}
