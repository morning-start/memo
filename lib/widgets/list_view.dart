import 'package:flutter/material.dart';

import 'package:memo/models/task_model.dart';
import 'package:memo/utils/app_theme.dart';

/// 任务列表视图组件
///
/// 用于显示任务列表的自定义组件，支持泛型约束，可显示任何继承自TaskModel的任务类型。
/// 该组件提供完整的任务管理功能，包括任务状态切换、编辑和删除操作。
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
    required this.toggleFunc,
    required this.delFunc,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          child: ListTile(
            title: Text(
              item.title,
              style: AppTypography.titleMedium(isDark).copyWith(
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
                color: item.isCompleted
                    ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary)
                    : null,
              ),
            ),
            subtitle: subtitleBuilder != null ? subtitleBuilder!(item) : null,
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (value) => toggleFunc(item.id),
              activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary),
              onPressed: () => delFunc(item.id),
            ),
            onTap: () => editFunc(item),
          ),
        );
      },
    );
  }
}
