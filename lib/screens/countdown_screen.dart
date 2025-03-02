import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/countdown_provider.dart';
import 'package:memo/widgets/list_view.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownProvider);
    final countdownNotifier = ref.read(countdownProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('倒计时'),
      ),
      body: TaskListView(
          items: countdowns,
          editFunc: (countdown) async {
            // 显示对话框以修改待办事项
          },
          toggleFunc: (id) {
            countdownNotifier.toggleCountdown(id);
          },
          delFunc: (id) {
            countdownNotifier.removeCountdown(id);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 显示对话框以添加新的待办事项
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
