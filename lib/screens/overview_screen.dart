import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/routine_model.dart';
import 'package:memo/providers/group_provider.dart';
import 'package:memo/providers/routine_provider.dart';
import 'package:memo/utils/routine_logic.dart';
import 'package:memo/widgets/routine_dialog.dart';

/// 概览（首页）
///
/// 页面信息架构（与"长期规划要提前准备"的定位一致）：
/// - 顶部：本周概览统计卡（已逾期 / 本周待处理 / 进行中）
/// - 主体：未来 7 天即将到期 + 已逾期的规律事项，按紧急程度排序
///   让用户在到期前几天甚至前几周就能看得到、有时间准备，
///   而不是到"当天"才被告知。
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final groups = ref.watch(groupsProvider);
    final groupNameOf = <String, String>{
      for (final g in groups) g.id: g.name,
    };

    // 参与统计的：未暂停的任务
    final active = routines.where((r) => !r.isPaused).toList();
    final overdue = active
        .where((r) => routineStatus(r) == RoutineStatus.overdue)
        .toList();
    // 未来 7 天内到期（含今天），不含已逾期 → 仅用于"本周待处理"统计
    final dueThisWeek = active.where((r) {
      final d = daysUntil(r.nextDue);
      return d >= 0 && d <= 7;
    }).toList();
    // 已进入各自提前提醒窗口（按每个任务的 warnLeadDays，可能超过 7 天）
    // 例：一年周期提前 1 月的任务也会在此出现，而无需等到当周 → 需准备列表
    final dueSoon = active
        .where((r) => routineStatus(r) == RoutineStatus.dueSoon)
        .toList();
    // 合并展示：已逾期优先，随后进入提前提醒期的任务
    final weekly = [...overdue, ...dueSoon]
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: routines.isEmpty
              ? _buildEmpty(context, ref)
              : RefreshIndicator(
                  onRefresh: () => ref.read(routinesProvider.notifier).reload(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildHeader(context),
                      _buildStats(context, active.length, overdue.length,
                          overdue.length + dueThisWeek.length),
                      _buildSectionTitle(context, weekly),
                      for (final r in weekly)
                        _routineRow(context, r, groupNameOf),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showRoutineDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新建规律事项'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights, size: 64, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            const Text('欢迎使用',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              '把"每多久做一次"的事情记下来，\n完成后自动重新计时，不再为遗忘担忧',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => showRoutineDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('设定第一个长期任务'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(
            '本周概览',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            '${dateShort(weekStart)} - ${dateShort(weekEnd)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, int active, int overdue, int dueSoon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _statCard(context, '已逾期', overdue, Colors.red),
          const SizedBox(width: 10),
          _statCard(context, '本周待处理', overdue + dueSoon, Colors.orange),
          const SizedBox(width: 10),
          _statCard(context, '进行中', active, Colors.blue),
        ],
      ),
    );
  }

  Widget _statCard(
      BuildContext context, String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, List<Routine> weekly) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        weekly.isEmpty ? '当前没有需要提前准备的任务' : '进入提前提醒期，请着手准备',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _routineRow(BuildContext context, Routine r, Map<String, String> groupNameOf) {
    final status = routineStatus(r);
    final color = switch (status) {
      RoutineStatus.overdue => Colors.red,
      RoutineStatus.dueSoon => Colors.orange,
      RoutineStatus.normal => Theme.of(context).colorScheme.primary,
    };
    final groupName = r.groupId == null || r.groupId!.isEmpty
        ? null
        : groupNameOf[r.groupId];
    final subtitleParts = <String>[
      intervalLabel(r.intervalDays),
      if (r.warnLeadDays != 7) remindLeadLabel(r.warnLeadDays),
      nextDueLabel(r),
      if (groupName != null) '所属：$groupName',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(
          status == RoutineStatus.overdue
              ? Icons.error_outline
              : Icons.event,
          color: color,
        ),
        title: Text(r.title,
            style: TextStyle(
              fontWeight: status == RoutineStatus.overdue
                  ? FontWeight.w600
                  : FontWeight.normal,
            )),
        subtitle: Text(subtitleParts.join(' · ')),
        onTap: () => showRoutineDialog(context, ref, editing: r),
      ),
    );
  }
}