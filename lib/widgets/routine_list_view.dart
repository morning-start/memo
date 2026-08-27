import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/group_model.dart';
import 'package:memo/models/routine_model.dart';
import 'package:memo/providers/group_provider.dart';
import 'package:memo/providers/routine_provider.dart';
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
        children: children,
      ),
    );
  }

  /// 空状态引导
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.autorenew, size: 56, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            const Text('还没有长期 / 规律任务',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '为"每多久做一次"的事情设定任务，\n完成后自动重新计时，不用记下一次时间',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => showRoutineDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('新建规律事项'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade400,
        ),
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
    final anyOverdue = active.any((r) => routineStatus(r) == RoutineStatus.overdue);
    final anyDueSoon = active.any((r) => routineStatus(r) == RoutineStatus.dueSoon);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ExpansionTile(
          leading: Icon(
            Icons.folder,
            color: anyOverdue
                ? Colors.red
                : (anyDueSoon
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary),
          ),
          title: Text(group.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: '在该分组下新建任务',
                onPressed: () =>
                    showRoutineDialog(context, ref, presetGroupId: group.id),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
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
  Widget _routineTile(BuildContext context, Routine r, RoutineNotifier notifier) {
    final status = routineStatus(r);
    final color = switch (status) {
      RoutineStatus.overdue => Colors.red,
      RoutineStatus.dueSoon => Colors.orange,
      RoutineStatus.normal => Theme.of(context).colorScheme.primary,
    };
    final interval = intervalLabel(r.intervalDays);
    final lead = r.warnLeadDays != 7 ? ' · ${remindLeadLabel(r.warnLeadDays)}提醒' : '';

    final subtitle = r.isPaused
        ? '已暂停 · $interval · 原为${nextDueLabel(r)}'
        : '$interval$lead · 下次 ${dateShort(r.nextDue)}（${nextDueLabel(r)}）';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      // 标记完成：核心"自动重置"动作
      leading: IconButton(
        icon: Icon(r.isPaused ? Icons.pause_circle_outline : Icons.check_circle_outline,
            color: r.isPaused ? Colors.grey : color),
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
        style: TextStyle(
          color: r.isPaused ? Colors.grey : null,
          fontWeight: switch (status) {
            RoutineStatus.overdue => FontWeight.w600,
            _ => FontWeight.normal,
          },
        ),
      ),
      subtitle: Text(subtitle),
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
          PopupMenuItem(
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