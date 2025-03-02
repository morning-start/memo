import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // 引入refresher库
import '../providers/countdown_provider.dart';

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
      body: ListView.builder(
          itemCount: countdowns.length,
          itemBuilder: (context, index) {
            final countdown = countdowns[index];
            return ListTile(
              title: Text(
                countdown.title,
                style: TextStyle(
                  decoration:
                      countdown.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              // subtitle: ,
              leading: Checkbox(
                  value: countdown.isCompleted,
                  onChanged: (val) {
                    countdownNotifier.toggleCountdown(countdown.id);
                  }),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  countdownNotifier.removeCountdown(countdown.id);
                },
              ),
            );
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
