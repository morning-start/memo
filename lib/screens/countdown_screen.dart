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
        subtitleBuilder: (countdown) {
          final now = DateTime.now();
          final elapsedDays = now.difference(countdown.startTime).inDays;
          final totalDays = countdown.duration.inDays;
          final progress = elapsedDays / totalDays;

          return Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress, // 进度值，范围为 0.0 到 1.0
                  backgroundColor: Colors.grey[300], // 背景颜色
                  color: Colors.blue, // 进度条颜色
                ),
              ),
              const SizedBox(width: 8),
              Text('$elapsedDays/$totalDays'),
            ],
          );
        },
        editFunc: (countdown) async {
          final result = await _showCountdownDialog(
            context,
            countdown.title,
            countdown.startTime,
            countdown.duration,
            countdown.isRecurring,
          );
          if (result != null) {
            countdownNotifier.updateCountdown(
              countdown.id,
              result['title'] as String,
              result['startTime'] as DateTime,
              result['duration'] as Duration,
              result['isRecurring'] as bool,
            );
          }
        },
        toggleFunc: (id) {
          countdownNotifier.toggleCountdown(id);
        },
        delFunc: (id) {
          countdownNotifier.removeCountdown(id);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _showCountdownDialog(
            context,
            '',
            DateTime.now(),
            Duration(days: 1),
            false,
          );
          if (result != null) {
            countdownNotifier.addCountdown(
              result['title'] as String,
              result['startTime'] as DateTime,
              result['duration'] as Duration,
              result['isRecurring'] as bool,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showCountdownDialog(
    BuildContext context,
    String oldTitle,
    DateTime oldStartTime,
    Duration oldDuration,
    bool oldIsRecurring,
  ) async {
    // 初始化变量
    String title = oldTitle;
    DateTime startTime = oldStartTime;
    Duration duration = oldDuration;
    bool isRecurring = oldIsRecurring;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(oldTitle.isEmpty ? '添加倒计时' : '修改倒计时'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 输入标题
              TextField(
                controller: TextEditingController(text: oldTitle),
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(
                  hintText: '输入倒计时标题',
                  labelText: '标题',
                ),
              ),
              const SizedBox(height: 10),

              // 选择开始时间
              ElevatedButton(
                onPressed: () async {
                  final pickedDateTime = await _pickDate(context, startTime);
                  if (pickedDateTime != null) {
                    startTime = pickedDateTime;
                  }
                },
                child: const Text('选择开始时间'),
              ),
              const SizedBox(height: 10),

              // 设置持续时间（天数）
              ElevatedButton(
                onPressed: () async {
                  final days = await _setDurationDays(context);
                  if (days != null) {
                    duration = Duration(days: days);
                  }
                },
                child: const Text('设置持续时间'),
              ),
              const SizedBox(height: 10),

              // 是否重复
              Row(
                children: [
                  Checkbox(
                    value: isRecurring,
                    onChanged: (value) {
                      isRecurring = !isRecurring;
                    },
                  ),
                  Text("重复"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'title': title,
                  'startTime': startTime,
                  'duration': duration,
                  'isRecurring': isRecurring,
                });
              },
              child: Text(oldTitle.isEmpty ? '添加' : '保存'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _setDurationDays(BuildContext context) async {
    int? days = await _showDaysPicker(
      context: context,
      title: '选择天数',
      min: 1,
      max: 365,
    );
    return days;
  }

  Future<int?> _showDaysPicker({
    required BuildContext context,
    required String title,
    required int min,
    required int max,
  }) async {
    int value = min;

    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '请输入天数'),
                  onChanged: (text) {
                    int? parsedValue = int.tryParse(text);
                    if (parsedValue != null &&
                        parsedValue >= min &&
                        parsedValue <= max) {
                      value = parsedValue;
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // 取消时返回 null
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(value); // 确定时返回选择的天数
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _pickDate(
      BuildContext context, DateTime initialDateTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(1900), // 允许选择从1900年开始的日期
      lastDate: DateTime(2100), // 最大日期仍然设置为2100年
    );
    return pickedDate;
  }
}
