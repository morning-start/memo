import 'package:flutter/material.dart';

import 'package:memo/screens/countdown_screen.dart';
import 'package:memo/screens/settings_screen.dart';
import 'package:memo/screens/todo_list_screen.dart';

// 导入 db_seeder.dart 文件
// 确保 Todo 模型可用
class Route {
  final String name;
  final Widget screen;
  final BottomNavigationBarItem item;

  Route({required this.name, required this.screen, required this.item});
}

final List<Route> routes = [
  Route(
    name: 'todoList',
    screen: const TodoListScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: '待办列表',
    ),
  ),
  Route(
    name: 'countdown',
    screen: const CountdownScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.timer),
      label: '倒计时列表',
    ),
  ),
  Route(
    name: 'settings',
    screen: const SettingsScreen(),
    item: const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '设置',
    ),
  ),
];
