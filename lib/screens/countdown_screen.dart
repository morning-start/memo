import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/countdown_provider.dart';
import 'package:memo/utils/sustain.dart';
import 'package:memo/widgets/info_button.dart';
import 'package:memo/widgets/list_view.dart';

/// 倒计时页面
///
/// 显示和管理倒计时任务的用户界面，支持创建、编辑、删除和切换倒计时状态。
/// 该页面使用 Riverpod 进行状态管理，通过 ConsumerWidget 响应状态变化。
///
/// 功能特点：
/// - 展示所有倒计时任务列表，包括进度条显示
/// - 支持添加新倒计时任务
/// - 支持编辑现有倒计时任务的标题、开始时间、持续时间和循环设置
/// - 支持切换倒计时完成状态和删除任务
/// - 提供直观的进度条显示剩余时间
///
/// 状态管理：
/// - 使用 countdownProvider 获取倒计时列表数据
/// - 使用 countdownProvider.notifier 执行状态变更操作
class CountdownScreen extends ConsumerWidget {
  /// 构造函数
  /// 
  /// 创建一个倒计时页面实例。
  const CountdownScreen({super.key});

  /// 构建页面UI
  /// 
  /// 根据当前状态构建倒计时页面的用户界面。
  /// 
  /// 参数：
  ///   - context: 构建上下文，用于访问主题、导航等
  ///   - ref: WidgetRef 引用，用于访问 Riverpod 状态
  /// 
  /// 返回值：构建好的页面 Widget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听倒计时列表状态变化
    final countdowns = ref.watch(countdownProvider);
    // 获取倒计时状态管理器，用于执行状态变更操作
    final countdownNotifier = ref.read(countdownProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('倒计时'),
      ),
      body: TaskListView(
        items: countdowns,
        // 构建每个倒计时项的副标题，显示进度条和剩余时间
        subtitleBuilder: (countdown) {
          final now = DateTime.now();
          // 计算已经过天数
          final elapsedDays = now.difference(countdown.startTime).inDays;
          // 获取总天数
          final totalDays = countdown.duration.totalDays;
          // 计算进度比例（0.0 到 1.0）
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
              // 显示已过天数/总天数
              Text('$elapsedDays/$totalDays'),
            ],
          );
        },
        // 编辑倒计时任务的回调函数
        editFunc: (countdown) async {
          final result = await _showCountdownDialog(
            context,
            countdown.title,
            countdown.startTime,
            countdown.duration,
            countdown.isRecurring,
          );
          if (result != null) {
            // 调用状态管理器更新倒计时任务
            countdownNotifier.updateCountdown(
              countdown.id,
              result['title'] as String,
              result['startTime'] as DateTime,
              result['duration'] as Sustain,
              result['isRecurring'] as bool,
            );
          }
        },
        // 切换倒计时完成状态的回调函数
        toggleFunc: (id) {
          countdownNotifier.toggleCountdown(id);
        },
        // 删除倒计时任务的回调函数
        delFunc: (id) {
          countdownNotifier.removeCountdown(id);
        },
      ),
      // 添加新倒计时任务的浮动操作按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _showCountdownDialog(
            context,
            '', // 空标题表示新建
            DateTime.now(), // 默认开始时间为当前时间
            Sustain(days: 1), // 默认持续时间为1天
            false, // 默认不循环
          );
          if (result != null) {
            // 调用状态管理器添加新的倒计时任务
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

  /// 显示倒计时编辑对话框
  /// 
  /// 弹出一个对话框，用于添加新倒计时或编辑现有倒计时。
  /// 对话框包含标题输入、开始时间选择、持续时间设置和循环选项。
  /// 
  /// 参数：
  ///   - context: 构建上下文
  ///   - oldTitle: 原始标题，空字符串表示新建
  ///   - oldStartTime: 原始开始时间
  ///   - oldDuration: 原始持续时间
  ///   - oldIsRecurring: 原始循环设置
  /// 
  /// 返回值：包含用户输入数据的 Map，如果用户取消则返回 null
  Future<Map<String, dynamic>?> _showCountdownDialog(
    BuildContext context,
    String oldTitle,
    DateTime oldStartTime,
    Sustain oldDuration,
    bool oldIsRecurring,
  ) async {
    // 初始化控制器和变量
    final titleController = TextEditingController(text: oldTitle);
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
                  // 标题输入框
                  TextField(
                    controller: titleController,
                    onChanged: (value) {
                      // 不需要 setState 调用，因为 TextEditingController 会自动更新
                    },
                    decoration: InputDecoration(
                      hintText: '输入倒计时标题',
                      labelText: '标题',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 开始时间选择按钮
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

                  // 持续时间设置按钮
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

                  // 循环选项复选框
                  Row(
                    children: [
                      Checkbox(
                        value: isRecurring,
                        onChanged: (value) {
                          setState(() {
                            isRecurring = value ?? false;
                          });
                        },
                      ),
                      const Text("重复"),
                    ],
                  ),
                ],
              ),
              actions: [
                // 取消按钮
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                // 确认按钮
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'title': titleController.text,
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

  /// 显示持续时间设置对话框
  /// 
  /// 弹出一个对话框，用于设置倒计时的持续时间（年、月、天）。
  /// 
  /// 参数：
  ///   - context: 构建上下文
  ///   - oldDuration: 原始持续时间
  /// 
  /// 返回值：新的 Sustain 对象，如果用户取消则返回 null
  Future<Sustain?> _setDuration(BuildContext context, Sustain oldDuration) async {
    final yearsController = TextEditingController(text: oldDuration.years.toString());
    final monthsController = TextEditingController(text: oldDuration.months.toString());
    final daysController = TextEditingController(text: oldDuration.days.toString());

    return await showDialog<Sustain>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置持续时间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 年数输入框
              TextField(
                controller: yearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '年'),
                onChanged: (value) {
                  // 不需要 setState 调用，因为 TextEditingController 会自动更新
                },
              ),
              // 月数输入框
              TextField(
                controller: monthsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '月'),
                onChanged: (value) {
                  // 不需要 setState 调用
                },
              ),
              // 天数输入框
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '天'),
                onChanged: (value) {
                  // 不需要 setState 调用
                },
              ),
            ],
          ),
          actions: [
            // 取消按钮
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // 取消时返回 null
              },
              child: const Text('取消'),
            ),
            // 确定按钮
            TextButton(
              onPressed: () {
                // 解析输入值，如果无法解析则默认为0
                int years = int.tryParse(yearsController.text) ?? 0;
                int months = int.tryParse(monthsController.text) ?? 0;
                int days = int.tryParse(daysController.text) ?? 0;
                Navigator.of(context).pop(Sustain(years: years, months: months, days: days));
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示日期选择器
  /// 
  /// 弹出系统日期选择器，允许用户选择日期。
  /// 
  /// 参数：
  ///   - context: 构建上下文
  ///   - initialDateTime: 初始日期时间
  /// 
  /// 返回值：用户选择的日期，如果用户取消则返回 null
  Future<DateTime?> _pickDate(
      BuildContext context, DateTime initialDateTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(1900), // 允许选择从1900年开始的日期
      lastDate: DateTime(3000), // 最大日期设置为3000年，确保足够大的选择范围
    );
    return pickedDate;
  }
}