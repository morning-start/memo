import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局主题模式状态提供者
///
/// 使用 StateNotifierProvider 管理应用的主题模式状态，
/// 支持浅色/深色主题切换，并持久化用户偏好设置。
///
/// 使用示例：
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final themeMode = ref.watch(themeModeProvider);
///     return MaterialApp(
///       themeMode: themeMode,
///       // ...
///     );
///   }
/// }
///
/// 返回值：ThemeMode 枚举值（light/dark）
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// 主题模式状态管理器
///
/// 负责管理应用的主题模式，包括：
/// - 初始化时从 SharedPreferences 加载用户保存的主题偏好
/// - 处理主题切换逻辑
/// - 将主题变更持久化到本地存储
///
/// 实现原理：
/// - 使用 StateNotifier 管理不可变状态
/// - 通过 SharedPreferences 持久化用户偏好
/// - 采用异步初始化模式，避免阻塞 UI 线程
///
/// 状态流程：
/// 1. 应用启动时创建 ThemeModeNotifier 实例
/// 2. 异步加载保存的主题偏好
/// 3. 用户切换主题时更新状态并持久化
/// 4. UI 组件自动响应状态变更
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  /// 构造函数
  ///
  /// 初始化时设置默认主题为浅色模式，并异步加载保存的主题偏好。
  /// 采用异步初始化模式确保应用快速启动，避免阻塞 UI 线程。
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  /// 从本地存储加载主题模式偏好
  ///
  /// 读取 SharedPreferences 中保存的 'isDarkTheme' 值，
  /// 根据存储值设置当前主题模式。如果未找到保存的值，
  /// 保持默认的浅色主题。
  ///
  /// 执行流程：
  /// 1. 获取 SharedPreferences 实例
  /// 2. 读取 'isDarkTheme' 键值
  /// 3. 根据布尔值设置主题模式状态
  /// 4. 触发 UI 更新反映主题变更
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool('isDarkTheme');
    state = isDarkTheme == true ? ThemeMode.dark : ThemeMode.light;
  }

  /// 将主题模式保存到本地存储
  ///
  /// 参数：
  ///   - mode: 要保存的主题模式（ThemeMode.light 或 ThemeMode.dark）
  /// 
  /// 将主题模式转换为布尔值存储，确保用户偏好跨应用启动持久化。
  ///
  /// 存储规则：
  /// - ThemeMode.dark → true
  /// - ThemeMode.light → false
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', mode == ThemeMode.dark);
  }

  /// 切换当前主题模式
  ///
  /// 在浅色和深色主题之间切换，并自动保存新的主题偏好。
  /// 切换后立即更新状态，触发依赖该状态的UI组件重新构建。
  ///
  /// 切换逻辑：
  /// - 当前为浅色主题 → 切换为深色主题
  /// - 当前为深色主题 → 切换为浅色主题
  ///
  /// 副作用：
  /// - 更新内部状态
  /// - 持久化用户偏好
  /// - 触发所有监听组件重建
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(state);
  }
}
