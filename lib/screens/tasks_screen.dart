import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/todo_provider.dart';
import 'package:memo/widgets/routine_dialog.dart';
import 'package:memo/widgets/routine_list_view.dart';
import 'package:memo/widgets/todo_list_view.dart';

/// 任务页（分段：规律事项 / 待办）
///
/// 承接应用的两种任务形态：
/// - 规律事项：长期 / 周期任务，完成后自动重置下次到期（核心）
/// - 待办：一次性、带截止日期的任务
///
/// 页面信息架构：
/// - 顶部 Tab 分段切换两种任务
/// - 右下角 FAB 随当前分段变化：规律事项→新建规律事项，待办→新建待办
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onFabPressed() async {
    if (_tabIndex == 0) {
      await showRoutineDialog(context, ref);
    } else {
      final result = await showTodoDialog(context, ref);
      if (result != null) {
        await ref.read(todoListProvider.notifier).addTodo(
              result['title'] as String,
              result['deadline'] as DateTime,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: '规律事项'),
                Tab(text: '待办'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RoutineListView(),
          TodoListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        icon: const Icon(Icons.add_rounded),
        label: Text(_tabIndex == 0 ? '新建规律事项' : '新建待办'),
      ),
    );
  }
}