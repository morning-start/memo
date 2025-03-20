import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/countdown_provider.dart';
import 'package:memo/utils/sustain.dart';
import 'package:memo/widgets/info_button.dart';
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
          final totalDays = countdown.duration.totalDays;
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
              result['duration'] as Sustain,
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
            Sustain(days: 1),
            false,
          );
          if (result != null) {
            countdownNotifier.addCountdown(
              result['title'] as String,
              result['startTime'] as DateTime,
              result['duration'] as Sustain,
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
    Sustain oldDuration,
    bool oldIsRecurring,
  ) async {
    // 初始化变量
    String title = oldTitle;
    DateTime startTime = oldStartTime;
    Sustain duration = oldDuration;
    bool isRecurring = oldIsRecurring;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(oldTitle.isEmpty ? '添加倒计时' : '修改倒计时'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 输入标题
                  TextField(
                    controller: TextEditingController(text: title),
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '输入倒计时标题',
                      labelText: '标题',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 选择开始时间
                  InfoButton(
                      onPressed: () async {
                        final pickedDateTime =
                            await _pickDate(context, startTime);
                        if (pickedDateTime != null) {
                          setState(() {
                            startTime = pickedDateTime;
                          });
                        }
                      },
                      label: '选择开始时间',
                      feedback:
                          '${startTime.year}-${startTime.month}-${startTime.day}'),
                  const SizedBox(height: 10),

                  // 设置持续时间（年、月、天）
                  InfoButton(
                      onPressed: () async {
                        final newDuration = await _setDuration(context, duration);
                        if (newDuration != null) {
                          setState(() {
                            duration = newDuration;
                          });
                        }
                      },
                      label: '设置持续时间',
                      feedback: '${duration.years} 年 ${duration.months} 月 ${duration.days} 天'),
                  const SizedBox(height: 10),

                  // 是否重复
                  Row(
                    children: [
                      Checkbox(
                        value: isRecurring,
                        onChanged: (value) {
                          setState(() {
                            isRecurring = !isRecurring;
                          });
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
      },
    );
  }

  Future<Sustain?> _setDuration(BuildContext context, Sustain oldDuration) async {
    int years = oldDuration.years;
    int months = oldDuration.months;
    int days = oldDuration.days;

    return await showDialog<Sustain>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置持续时间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '年'),
                onChanged: (text) {
                  int? parsedValue = int.tryParse(text);
                  if (parsedValue != null) {
                    years = parsedValue;
                  }
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '月'),
                onChanged: (text) {
                  int? parsedValue = int.tryParse(text);
                  if (parsedValue != null) {
                    months = parsedValue;
                  }
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '天'),
                onChanged: (text) {
                  int? parsedValue = int.tryParse(text);
                  if (parsedValue != null) {
                    days = parsedValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // 取消时返回 null
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(Sustain(years: years, months: months, days: days));
              },
              child: const Text('确定'),
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
      lastDate: DateTime(3000), // 最大日期仍然设置为2100年
    );
    return pickedDate;
  }
}    