import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/theme_provider.dart';

/// 主题切换瓦片组件
/// 
/// 用于在设置界面中提供主题切换功能的瓦片组件，支持深色模式和浅色模式之间的切换。
/// 该组件使用Riverpod进行状态管理，通过ThemeProvider来控制应用的主题模式。
/// 
/// 功能特点：
/// - 实时显示当前主题状态（深色/浅色模式图标）
/// - 点击瓦片或图标按钮均可切换主题
/// - 使用ConsumerWidget监听主题状态变化
/// - 响应式UI设计，适配不同屏幕尺寸
/// 
/// 使用示例：
/// ```dart
/// ExchangeTile(
///   title: "主题切换",
/// )
/// ```
/// 
/// 注意事项：
/// - 需要确保ThemeProvider已在应用中正确配置
/// - 主题切换会立即生效并持久化存储
/// - 组件依赖Riverpod状态管理，必须在Provider作用域内使用
class ExchangeTile extends ConsumerWidget {
  /// 瓦片标题文本
  /// 
  /// 显示在瓦片左侧的主要文本内容，通常用于描述功能名称。
  final String title;

  /// 构造函数
  /// 
  /// 创建一个主题切换瓦片组件实例。
  /// 
  /// [key] 用于组件标识的可选键
  /// [title] 瓦片标题文本，必填参数
  const ExchangeTile({super.key, required this.title});

  /// 切换主题模式
  /// 
  /// 通过ThemeProvider切换应用的主题模式（深色/浅色模式）。
  /// 该方法会调用themeModeNotifier的toggleTheme方法来实现主题切换。
  /// 
  /// [ref] WidgetRef引用，用于访问Riverpod提供的状态
  /// 
  /// 代码逻辑：
  /// 1. 获取themeModeProvider的notifier实例
  /// 2. 调用toggleTheme方法切换主题模式
  /// 3. 主题状态变化会自动触发UI更新
  void changeTheme(WidgetRef ref) {
    // 获取主题模式通知器
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    // 切换主题模式
    themeModeNotifier.toggleTheme();
  }

  /// 构建组件UI
  /// 
  /// 构建主题切换瓦片的用户界面，包括标题文本和主题切换按钮。
  /// 使用ListTile作为基础布局，右侧显示当前主题状态对应的图标。
  /// 
  /// [context] 构建上下文
  /// [ref] WidgetRef引用，用于访问Riverpod状态
  /// 
  /// 返回配置好的ListTile组件
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      // 显示瓦片标题
      title: Text(title),
      // 点击瓦片切换主题
      onTap: () => changeTheme(ref),
      // 右侧主题切换图标按钮
      trailing: IconButton(
        // 根据当前主题模式显示对应图标
        icon: Icon(
          ref.watch(themeModeProvider) == ThemeMode.dark
              ? Icons.dark_mode    // 深色模式显示月亮图标
              : Icons.light_mode,   // 浅色模式显示太阳图标
        ),
        // 点击图标切换主题
        onPressed: () => changeTheme(ref),
      ),
    );
  }
}
