import 'package:flutter/material.dart';

import 'package:memo/screens/countdown_screen.dart';
import 'package:memo/screens/settings_screen.dart';
import 'package:memo/screens/todo_list_screen.dart';

/// 路由配置文件
///
/// 定义应用程序的路由结构和底部导航栏配置，使用底部导航栏模式
/// 组织应用的主要功能页面。
///
/// 功能特点：
/// - 集中管理应用路由配置
/// - 定义底部导航栏项及其对应的页面
/// - 提供路由名称、页面组件和导航栏项的统一配置
/// - 支持扩展新的路由页面
///
/// 使用示例：
/// ```dart
/// // 获取路由列表
/// final routeList = routes;
/// 
/// // 获取第一个路由的页面
/// Widget firstScreen = routes.first.screen;
/// 
/// // 获取所有导航栏项
/// List<BottomNavigationBarItem> navItems = 
///     routes.map((route) => route.item).toList();
/// 
/// // 根据索引获取路由
/// Route currentRoute = routes[index];
/// ```
///
/// 注意事项：
/// - 添加新路由时，需要确保对应的页面组件已正确导入
/// - 路由名称应简洁明了，反映页面功能
/// - 导航栏图标和标签应与应用整体风格保持一致

/// 路由数据模型
///
/// 封装路由的基本信息，包括路由名称、对应的页面组件和底部导航栏项。
/// 此模型用于统一管理应用的路由配置，便于维护和扩展。
///
/// 属性说明：
///   - name - String，路由名称，用于标识和区分不同路由
///   - screen - Widget，路由对应的页面组件
///   - item - BottomNavigationBarItem，底部导航栏项，包含图标和标签
class Route {
  /// 路由名称，用于标识和区分不同路由
  final String name;
  
  /// 路由对应的页面组件
  final Widget screen;
  
  /// 底部导航栏项，包含图标和标签
  final BottomNavigationBarItem item;

  /// 构造函数
  /// 
  /// 创建一个新的路由实例，需要提供路由名称、页面组件和导航栏项。
  /// 
  /// 参数：
  ///   - name - String，路由名称
  ///   - screen - Widget，路由对应的页面组件
  ///   - item - BottomNavigationBarItem，底部导航栏项
  Route({required this.name, required this.screen, required this.item});
}

/// 应用程序路由列表
///
/// 定义应用程序的所有主要路由及其对应的底部导航栏配置。
/// 当前包含三个主要功能页面：待办列表、倒计时列表和设置页面。
///
/// 路由列表说明：
///   - 待办列表：显示和管理用户的待办事项
///   - 倒计时列表：显示和管理用户的倒计时任务
///   - 设置：提供应用设置和配置选项
final List<Route> routes = [
  // 待办列表路由
  Route(
    name: 'todoList',
    screen: const TodoListScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: '待办列表',
    ),
  ),
  
  // 倒计时列表路由
  Route(
    name: 'countdown',
    screen: const CountdownScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.timer),
      label: '倒计时列表',
    ),
  ),
  
  // 设置页面路由
  Route(
    name: 'settings',
    screen: const SettingsScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '设置',
    ),
  ),
];
