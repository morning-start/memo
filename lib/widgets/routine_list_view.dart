import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/group_model.dart';
import 'package:memo/models/routine_model.dart';
import 'package:memo/providers/group_provider.dart';
import 'package:memo/providers/routine_provider.dart';
import 'package:memo/utils/app_theme.dart';
import 'package:memo/utils/routine_logic.dart';
import 'package:memo/widgets/routine_dialog.dart';

/// 规律事项列表（分组 + 可展开 + 自动重置）
///
/// 页面信息架构：
/// - 未分组任务：顶层平铺，按下次到期排序
/// - 分组任务：以可展开的分组卡片组织，每个子项有独立周期与独立自动重置
///
/// 核心交互：
/// - 点任务标题/空白处：编辑该任务
/// - 点行首圆圈：标记完成，下次到期自动顺延（无需记时间点）
/// - 长按 / 点行尾更多菜单：完成、暂停/恢复、编辑、删除
class RoutineListView extends ConsumerStatefulWidget {
  const RoutineListView({super.key});

  @override
  ConsumerState<RoutineListView> createState() => _RoutineListViewState();
}

class _RoutineListViewState extends ConsumerState<RoutineListView> {
  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routinesProvider);
    final groups = ref.watch(groupsProvider);
    final notifier = ref.read(routinesProvider.notifier);

    // 分割：未分组与属于分组
    final ungrouped = routines
        .where((r) => r.groupId == null || r.groupId!.isEmpty)
        .toList()
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));

    if (routines.isEmpty) {
      return _buildEmpty();
    }

    final children = <Widget>[];
    if (ungrouped.isNotEmpty) {
      children.add(_sectionHeader('常规任务'));
      children.addAll(ungrouped.map((r) => _routineTile(context, r, notifier)));
    }
    for (final group in groups) {
      final inGroup = routines.where((r) => r.groupId == group.id).toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      if (inGroup.isEmpty) continue;
      children.add(_groupTile(context, group, inGroup, notifier));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.reload(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: children,
      ),
    );
  }

  /// 空状态引导
  Widget _buildEmpty() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
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
              child: Icon(Icons.autorenew_rounded,
                  size: 40, color: cs.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('还没有长期 / 规律任务',
                style: AppTypography.titleMedium(isDark)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '为"每多久做一次"的事情设定任务，\n完成后自动重新计时，不用记下一次时间',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(isDark),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: () => showRoutineDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新建规律事项'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.labelLarge(isDark),
      ),
    );
  }

  /// 分组卡片（可展开），展示聚合状态
  Widget _groupTile(
    BuildContext context,
    Group group,
    List<Routine> routinesInGroup,
    RoutineNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    // 计算聚合：最近到期的未暂停子项
    final active = routinesInGroup.where((r) => !r.isPaused).toList();
    String subtitle;
    if (active.isEmpty) {
      subtitle = '全部已暂停，${routinesInGroup.length} 个子任务';
    } else {
      active.sort((a, b) => a.nextDue.compareTo(b.nextDue));
      final nearest = active.first;
      final days = daysUntil(nearest.nextDue);
      final when =
          days < 0 ? '已逾期 ${-days} 天' : (days == 0 ? '今天到期' : '$days 天后');
      subtitle = '最近到期：${nearest.title} · $when';
    }
    final anyOverdue =
        active.any((r) => routineStatus(r) == RoutineStatus.overdue);
    final anyDueSoon =
        active.any((r) => routineStatus(r) == RoutineStatus.dueSoon);

    final folderColor = anyOverdue
        ? AppColors.overdue
        : (anyDueSoon
            ? AppColors.dueSoon
            : (isDark ? AppColors.darkPrimary : AppColors.primary));

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: ExpansionTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: folderColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.folder_rounded, color: folderColor, size: 20),
          ),
          title: Text(group.name,
              style: AppTypography.titleMedium(isDark)),
          subtitle: Text(subtitle,
              style: AppTypography.bodyMedium(isDark)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 20),
                tooltip: '在该分组下新建任务',
                onPressed: () =>
                    showRoutineDialog(context, ref, presetGroupId: group.id),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                tooltip: '分组操作',
                onPressed: () => showGroupMenu(context, ref, group),
              ),
            ],
          ),
          children: [
            for (final r in routinesInGroup) _routineTile(context, r, notifier),
          ],
        ),
      ),
    );
  }

  /// 单个规律事项行
  Widget _routineTile(
      BuildContext context, Routine r, RoutineNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final status = routineStatus(r);
    final color = switch (status) {
      RoutineStatus.overdue => AppColors.overdue,
      RoutineStatus.dueSoon => AppColors.dueSoon,
      RoutineStatus.normal => isDark ? AppColors.darkPrimary : AppColors.primary,
    };
    final interval = intervalLabel(r.intervalDays);
    final lead = r.warnLeadDays != 7
        ? ' · ${remindLeadLabel(r.warnLeadDays)}提醒'
        : '';

    final subtitle = r.isPaused
        ? '已暂停 · $interval · 原为${nextDueLabel(r)}'
        : '$interval$lead · 下次 ${dateShort(r.nextDue)}（${nextDueLabel(r)}）';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
      leading: IconButton(
        icon: Icon(
          r.isPaused
              ? Icons.pause_circle_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: r.isPaused ? AppColors.paused : color,
        ),
        tooltip: r.isPaused ? '恢复（点击行首继续参与提醒）' : '标记完成，自动重新计时',
        onPressed: () {
          if (r.isPaused) {
            notifier.togglePause(r.id);
          } else {
            notifier.markCompleted(r.id);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text('已为「${r.title}」标记完成，下次到期已顺延为 $interval'),
                duration: const Duration(seconds: 2),
              ));
          }
        },
      ),
      title: Text(
        r.title,
        style: AppTypography.titleMedium(isDark).copyWith(
          color: r.isPaused
              ? (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
              : null,
          fontWeight: switch (status) {
            RoutineStatus.overdue => FontWeight.w700,
            _ => FontWeight.w500,
          },
        ),
      ),
      subtitle: Text(subtitle, style: AppTypography.bodyMedium(isDark)),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'complete':
              notifier.markCompleted(r.id);
            case 'pause':
              notifier.togglePause(r.id);
            case 'edit':
              showRoutineDialog(context, ref, editing: r);
            case 'delete':
              _confirmDelete(context, notifier, r);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'complete',
            child: Text('标记完成（自动重计时）'),
          ),
          PopupMenuItem(
            value: 'pause',
            child: Text(r.isPaused ? '恢复提醒' : '暂停提醒'),
          ),
          const PopupMenuItem(value: 'edit', child: Text('编辑')),
          const PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => showRoutineDialog(context, ref, editing: r),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, RoutineNotifier notifier, Routine r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: Text('确定删除「${r.title}」吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) notifier.removeRoutine(r.id);
  }
}
