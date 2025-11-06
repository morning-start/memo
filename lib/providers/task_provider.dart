import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/task_model.dart';
import 'package:memo/utils/db_helper.dart';

/// 任务状态管理抽象基类
///
/// 采用模板方法设计模式，为待办事项和倒计时任务提供统一的状态管理接口。
/// 该类定义了任务管理的通用操作，具体实现由子类通过 fromMap 方法完成。
/// 
/// 设计特点：
/// - 泛型设计支持不同类型的任务模型（Todo、Countdown）
/// - 继承 StateNotifier 实现响应式状态管理
/// - 封装数据库操作，提供统一的 CRUD 接口
/// - 支持数据同步后的状态刷新
///
/// 使用示例：
/// ```dart
/// class TodoNotifier extends TaskNotifier<Todo> {
///   TodoNotifier() : super(Todo.tableName);
///   
///   @override
///   Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);
/// }
/// ```
abstract class TaskNotifier<T extends TaskModel> extends StateNotifier<List<T>> {
  /// 数据库助手实例，延迟初始化以确保异步安全
  late DatabaseHelper _db;
  
  /// 数据库表名，由子类构造函数传入
  final String tableName;

  /// 构造函数
///
/// 参数：
  ///   - tableName: 对应的数据库表名（如 'todos'、'countdowns'）
  /// 
  /// 初始化时设置空列表状态，并异步初始化数据库连接
  TaskNotifier(this.tableName) : super([]) {
    _initializeDatabase();
  }

  /// 初始化数据库连接并加载初始数据
  /// 
  /// 创建 DatabaseHelper 实例，确保数据库准备就绪后加载任务列表。
  /// 采用异步初始化模式，避免阻塞 UI 线程。
  /// 
  /// 执行流程：
  /// 1. 创建 DatabaseHelper 实例
  /// 2. 调用 _loadTasks() 加载数据
  /// 3. 更新状态触发 UI 重建
  Future<void> _initializeDatabase() async {
    _db = DatabaseHelper();
    await _loadTasks();
  }

  /// 从数据库加载任务列表
  /// 
  /// 查询指定表中的所有记录，通过 fromMap 方法将数据库记录转换为模型对象。
  /// 更新状态后会自动通知所有监听该状态的 UI 组件重新构建。
  /// 
  /// 数据流程：
  /// 1. 执行数据库查询获取原始数据
  /// 2. 通过 fromMap 将每条记录转换为模型对象
  /// 3. 更新状态列表，触发 UI 更新
  Future<void> _loadTasks() async {
    final List<Map<String, dynamic>> maps = await _db.query(tableName);
    state = List.generate(maps.length, (i) {
      return fromMap(maps[i]);
    });
  }

  /// 将数据库记录映射为任务模型对象
  /// 
  /// 抽象方法，由子类实现具体的数据转换逻辑。
  /// 这是模板方法模式的关键，确保不同类型任务的正确实例化。
  /// 
  /// 参数：
  ///   - map: 数据库查询结果的字典数据
  /// 
  /// 返回：具体的任务模型实例（Todo 或 Countdown）
  /// 
  /// 实现示例：
  /// ```dart
  /// @override
  /// Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);
  /// ```
  T fromMap(Map<String, dynamic> map) => throw UnimplementedError();

  /// 添加新任务到数据库和状态列表
  /// 
  /// 将任务对象插入数据库，成功后更新状态列表。
  /// 采用不可变状态更新模式，创建新列表实例确保状态变更检测。
  /// 
  /// 参数：
  ///   - task: 要添加的任务模型对象
  /// 
  /// 执行流程：
  /// 1. 将任务对象转换为 Map 并插入数据库
  /// 2. 将任务对象添加到状态列表末尾
  /// 3. 触发状态更新，UI 自动响应变更
  Future<void> addTask(T task) async {
    await _db.insert(
      tableName,
      task.toMap(),
    );
    state = [...state, task];
  }

  /// 根据 ID 从数据库和状态列表中删除任务
  /// 
  /// 先执行数据库删除操作，确保数据一致性，然后更新状态列表。
  /// 使用 where 条件确保只删除指定 ID 的记录。
  /// 
  /// 参数：
  ///   - id: 要删除的任务唯一标识符
  /// 
  /// 执行流程：
  /// 1. 使用 where 条件从数据库删除指定记录
  /// 2. 从状态列表中过滤掉对应 ID 的任务
  /// 3. 触发状态更新，UI 自动响应变更
  Future<void> removeTask(String id) async {
    await _db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    state = state.where((task) => task.id != id).toList();
  }

  /// 切换指定任务的完成状态
  /// 
  /// 查找目标任务，调用其 changeStatus 方法切换完成状态，
  /// 然后调用 updateTask 更新数据库和状态。
  /// 
  /// 参数：
  ///   - id: 要切换状态的任务唯一标识符
  /// 
  /// 执行流程：
  /// 1. 从状态列表中查找指定 ID 的任务
  /// 2. 调用任务的 changeStatus() 方法切换状态
  /// 3. 调用 updateTask 持久化变更
  Future<void> toggleTask(String id) async {
    final tmp = state.firstWhere((task) => task.id == id);
    tmp.changeStatus();
    await updateTask(id, tmp);
  }

  /// 更新指定任务的信息
  /// 
  /// 将更新后的任务对象保存到数据库，并同步更新状态列表。
  /// 使用列表推导式确保状态更新的不可变性。
  /// 
  /// 参数：
  ///   - id: 要更新的任务唯一标识符
  ///   - task: 包含更新后数据的任务对象
  /// 
  /// 执行流程：
  /// 1. 使用 where 条件更新数据库中的记录
  /// 2. 创建新的状态列表，替换对应 ID 的任务
  /// 3. 触发状态更新，UI 自动响应变更
  Future<void> updateTask(String id, T task) async {
    await _db.update(
      tableName,
      task.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );
    state = [
      for (final task in state)
        if (task.id == id) task else task
    ];
  }

  /// 清空所有任务数据
  /// 
  /// 删除指定表中的所有记录，并将状态设置为空列表。
  /// 谨慎使用，通常用于测试或数据重置场景。
  /// 
  /// 执行流程：
  /// 1. 删除数据库表中的所有记录
  /// 2. 将状态设置为空列表
  /// 3. 触发状态更新，UI 自动响应变更
  /// 
  /// 注意：此操作不可逆，执行前应确认用户意图
  Future<void> clearTasks() async {
    await _db.delete(tableName);
    state = [];
  }

  /// 数据同步完成后的状态刷新
  /// 
  /// 在 WebDAV 同步操作完成后，重新打开数据库连接并重新加载数据。
  /// 确保同步后的数据变更能够正确反映在应用状态中。
  /// 
  /// 典型使用场景：
  /// - WebDAV 下载完成后刷新本地数据
  /// - 数据恢复操作完成后更新状态
  /// - 多设备同步后统一数据状态
  /// 
  /// 执行流程：
  /// 1. 关闭当前数据库连接
  /// 2. 重新打开数据库连接
  /// 3. 重新加载所有任务数据
  /// 4. 更新状态，触发 UI 刷新
  Future<void> refreshTasksAfterSync() async {
    await _db.reopenDatabase(); // 重新打开数据库
    await _loadTasks(); // 重新加载数据
  }
}