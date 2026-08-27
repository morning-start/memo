import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/group_model.dart';
import 'package:memo/utils/db_helper.dart';

/// 分组状态管理
///
/// 负责分组的增删改查与持久化，状态为当前全部分组的列表。
/// 分组用于把"一件需要拆成多个细碎事项"的事情组织起来（如「净水器」下
/// 挂「滤芯一/滤芯二」等多个独立周期任务）。
class GroupNotifier extends StateNotifier<List<Group>> {
  late final DatabaseHelper _db;

  GroupNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _db = DatabaseHelper();
    await reload();
  }

  /// 从数据库加载全部分组
  Future<void> reload() async {
    await _db.reopenDatabase();
    final maps = await _db.query(Group.tableName);
    state = [for (final map in maps) Group.fromMap(map)];
  }

  /// 新增分组
  Future<void> addGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final group = Group(name: trimmed);
    await _db.insert(Group.tableName, group.toMap());
    state = [...state, group];
  }

  /// 重命名分组
  Future<void> renameGroup(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final group = state.firstWhere((g) => g.id == id);
    group.rename(trimmed);
    await _db.update(
      Group.tableName,
      {'name': group.name},
      where: 'id = ?',
      whereArgs: [id],
    );
    state = [...state];
  }

  /// 删除分组（仅删除分组本身，子任务转为未分组）
  Future<void> removeGroup(String id) async {
    await _db.delete(Group.tableName, where: 'id = ?', whereArgs: [id]);
    state = state.where((g) => g.id != id).toList();
  }
}

/// 分组数据 Provider
final groupsProvider = StateNotifierProvider<GroupNotifier, List<Group>>(
  (ref) => GroupNotifier(),
);