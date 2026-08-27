import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/routine_model.dart';
import 'package:memo/providers/group_provider.dart';
import 'package:memo/providers/routine_provider.dart';
import 'package:memo/utils/app_theme.dart';
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
    final cs = Theme.of(context).colorScheme;
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
    final dueThisWeek = active.where((r) {
      final d = daysUntil(r.nextDue);
      return d >= 0 && d <= 7;
    }).toList();
    final dueSoon = active
        .where((r) => routineStatus(r) == RoutineStatus.dueSoon)
        .toList();
    final weekly = [...overdue, ...dueSoon]
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withOpacity(0.06),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: routines.isEmpty
              ? _buildEmpty(context, ref)
              : RefreshIndicator(
                  onRefresh: () => ref.read(routinesProvider.notifier).reload(),
                  child: ListView(
                    padding:
                        const EdgeInsets.only(top: AppSpacing.lg, bottom: 100),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.md),
                      _buildStats(
                          context, active.length, overdue.length,
                          overdue.length + dueThisWeek.length),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSectionTitle(context, weekly),
                      for (final r in weekly)
                        _routineRow(context, r, groupNameOf),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showRoutineDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('新建规律事项'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.insights_rounded,
                  size: 44, color: cs.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('欢迎使用',
                style: AppTypography.titleLarge(Theme.of(context).brightness ==
                        Brightness.dark)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '把"每多久做一次"的事情记下来，\n完成后自动重新计时，不再为遗忘担忧',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                  Theme.of(context).brightness == Brightness.dark),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: () => showRoutineDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('设定第一个长期任务'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本周概览',
                style: AppTypography.displayLarge(isDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${dateShort(weekStart)} — ${dateShort(weekEnd)}',
                style: AppTypography.bodyMedium(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      BuildContext context, int active, int overdue, int dueSoon) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 0),
      child: Row(
        children: [
          _statCard(context, '已逾期', overdue, AppColors.overdue),
          const SizedBox(width: AppSpacing.sm),
          _statCard(
              context, '本周待处理', overdue + dueSoon, AppColors.dueSoon),
          const SizedBox(width: AppSpacing.sm),
          _statCard(context, '进行中', active, AppColors.healthy),
        ],
      ),
    );
  }

  Widget _statCard(
      BuildContext context, String label, int value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceBright,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, List<Routine> weekly) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
      child: Text(
        weekly.isEmpty ? '当前没有需要提前准备的任务' : '进入提前提醒期，请着手准备',
        style: AppTypography.labelLarge(isDark),
      ),
    );
  }

  Widget _routineRow(
      BuildContext context, Routine r, Map<String, String> groupNameOf) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final status = routineStatus(r);
    final color = switch (status) {
      RoutineStatus.overdue => AppColors.overdue,
      RoutineStatus.dueSoon => AppColors.dueSoon,
      RoutineStatus.normal => isDark ? AppColors.darkPrimary : AppColors.primary,
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
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            status == RoutineStatus.overdue
                ? Icons.error_outline_rounded
                : Icons.event_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(r.title,
            style: AppTypography.titleMedium(isDark).copyWith(
              fontWeight: status == RoutineStatus.overdue
                  ? FontWeight.w700
                  : FontWeight.w500,
            )),
        subtitle: Text(subtitleParts.join(' · '),
            style: AppTypography.bodyMedium(isDark)),
        onTap: () => showRoutineDialog(context, ref, editing: r),
      ),
    );
  }
}
