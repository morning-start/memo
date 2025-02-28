import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // 引入refresher库
import '../providers/todo_provider.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final refreshController = RefreshController(); // 添加RefreshController

    return Scaffold(
      appBar: AppBar(
        title: const Text('倒计时'),
      ),
      body: SmartRefresher(
        // 使用SmartRefresher包裹ListView.builder
        controller: refreshController,
        onRefresh: () async {
          // 刷新逻辑，这里假设刷新时重新加载数据
          // ignore: unused_result
          ref.refresh(todoListProvider);
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            final remaining = todo.deadline.difference(DateTime.now());

            return ListTile(
              title: Text(todo.title),
              subtitle: Text(
                '剩余时间: ${remaining.inDays} 天 ${remaining.inHours % 24} 小时 ${remaining.inMinutes % 60} 分钟',
              ),
            );
          },
        ),
      ),
    );
  }
}
