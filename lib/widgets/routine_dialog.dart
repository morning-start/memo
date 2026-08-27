import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/group_model.dart';
import 'package:memo/models/routine_model.dart';
import 'package:memo/providers/group_provider.dart';
import 'package:memo/providers/routine_provider.dart';
import 'package:memo/utils/routine_logic.dart';

/// 弹出"新建/编辑规律事项"对话框。
///
/// 字段：
/// - 标题
/// - 所属分组（可"无分组"）
/// - 周期（从模板选择，如每1月、每3月、每1年）
/// - 预警提前量（默认提前1周，可按任务调整，如一年周期的大项可提前1月）
///
/// [editing] 不为空时进入编辑模式；[presetGroupId] 用于"在该分组下新建"。
Future<void> showRoutineDialog(
  BuildContext context,
  WidgetRef ref, {
  Routine? editing,
  String? presetGroupId,
}) async {
  final groups = ref.read(groupsProvider);
  final notifier = ref.read(routinesProvider.notifier);

  final titleController = TextEditingController(text: editing?.title ?? '');
  // '' 表示"无分组"
  String selectedGroupId = editing?.groupId ?? presetGroupId ?? '';
  int selectedInterval = editing?.intervalDays ?? 30;
  int selectedWarnLead = editing?.warnLeadDays ?? 7;

  // 构建周期候选，若当前值不在模板中则补充一项
  final intervalCandidates = <IntervalPreset>[...intervalPresets];
  if (!intervalCandidates.any((p) => p.days == selectedInterval)) {
    intervalCandidates.insert(
        0, IntervalPreset(intervalLabel(selectedInterval), selectedInterval));
  }
  // 构建预警提前量候选
  final warnLeadCandidates = <IntervalPreset>[...warnLeadPresets];
  if (!warnLeadCandidates.any((p) => p.days == selectedWarnLead)) {
    warnLeadCandidates.insert(
        0, IntervalPreset(intervalLabel(selectedWarnLead), selectedWarnLead));
  }

  // 分组下拉选项数据
  final groupItems = <({String id, String name})>[
    (id: '', name: '无分组'),
    for (final g in groups) (id: g.id, name: g.name),
  ];

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(editing == null ? '新建规律事项' : '编辑规律事项'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '标题',
                      hintText: '例如：更换净水器滤芯',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 所属分组
                  InputDecorator(
                    decoration: const InputDecoration(labelText: '所属分组'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGroupId,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          for (final item in groupItems)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                  item.id.isEmpty ? '无分组' : item.name),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedGroupId = value ?? '');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('周期', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final preset in intervalCandidates)
                        ChoiceChip(
                          label: Text(preset.label),
                          selected: selectedInterval == preset.days,
                          onSelected: (_) =>
                              setState(() => selectedInterval = preset.days),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('提前提醒',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const Text('默认提前 1 周。长周期的大项可改为提前 1 个月',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final preset in warnLeadCandidates)
                        ChoiceChip(
                          label: Text(preset.label),
                          selected: selectedWarnLead == preset.days,
                          onSelected: (_) =>
                              setState(() => selectedWarnLead = preset.days),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final isEdit = editing != null;
                  if (isEdit) {
                    notifier.updateRoutine(
                      id: editing.id,
                      title: titleController.text,
                      groupId: selectedGroupId,
                      intervalDays: selectedInterval,
                      warnLeadDays: selectedWarnLead,
                    );
                  } else {
                    notifier.addRoutine(
                      title: titleController.text,
                      groupId: selectedGroupId,
                      intervalDays: selectedInterval,
                      warnLeadDays: selectedWarnLead,
                    );
                  }
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// 弹出"新建分组"对话框。
Future<void> showGroupDialog(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(groupsProvider.notifier);
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('新建分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '例如：净水器、空调滤网',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.addGroup(controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}

/// 弹出一个确认 + 可输入名称的分组管理对话框（重命名 / 删除）。
void _handleGroupMenu(
  BuildContext context,
  WidgetRef ref,
  Group group,
) {
  final groupNotifier = ref.read(groupsProvider.notifier);
  final routineNotifier = ref.read(routinesProvider.notifier);
  // 该分组下的任务，用于删除时确认
  final routines = ref.read(routinesProvider);

  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(group.name),
              subtitle: const Text('分组操作'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('重命名'),
              onTap: () {
                Navigator.pop(context);
                _renameGroupDialog(context, groupNotifier, group);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除分组'),
              subtitle: Text('仅删除分组，${routines.where((r) => r.groupId == group.id).length} 个子任务转为未分组'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('删除分组'),
                    content: Text('确定删除分组「${group.name}」吗？分组下 ${routines.where((r) => r.groupId == group.id).length} 个子任务将转为未分组。'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  // 子任务移出分组
                  for (final r in routines.where((r) => r.groupId == group.id)) {
                    routineNotifier.updateRoutine(id: r.id, groupId: '');
                  }
                  await groupNotifier.removeGroup(group.id);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

/// 重命名分组输入对话框
Future<void> _renameGroupDialog(
  BuildContext context,
  GroupNotifier notifier,
  Group group,
) async {
  final controller = TextEditingController(text: group.name);
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('重命名分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.renameGroup(group.id, controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}

/// 供外层直接使用：调出分组长按/更多菜单
void showGroupMenu(BuildContext context, WidgetRef ref, Group group) {
  _handleGroupMenu(context, ref, group);
}