import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tools/db_seeder.dart'; // 导入 db_seeder.dart 文件
import 'models/todo_model.dart'; // 确保 Todo 模型可用
import 'models/countdown_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 框架初始化完成
  await initializeDatabase([Todo.sql, Countdown.sql]); // 初始化数据库并创建所需的表
  log('数据库初始化完成');
  // log 数据库中所有表名
  await openDatabase(join(await getDatabasesPath(), dbName)).then((db) async {
    final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    log('数据库中的表：${tables.map((row) => row['name']).join(', ')}');
  });


  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待办倒计时应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: route[_currentIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: route.map((group) => group.item).toList(),
      ),
    );
  }
}
