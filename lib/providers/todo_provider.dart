import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/models/todo_model.dart';
import 'package:memo/providers/task_provider.dart';

/// 待办事项状态管理器
///
/// 继承自 TaskNotifier 基类，专门处理待办事项的业务逻辑。
/// 提供待办事项的增删改查功能，包括添加新任务、切换完成状态、
/// 更新任务信息和删除任务等操作。
///
/// 设计特点：
/// - 封装待办事项特有的业务逻辑
/// - 复用 TaskNotifier 提供的通用数据库操作
/// - 提供类型安全的待办事项管理接口
/// - 通过 Riverpod 实现响应式状态管理
class TodoListNotifier extends TaskNotifier<Todo> {
  /// 构造函数
///
/// 调用父类构造函数，传入待办事项表名，初始化数据库连接和状态。
  TodoListNotifier() : super(Todo.tableName);
  

  /// 将数据库记录映射为 Todo 对象
  ///
  /// 实现父类抽象方法，将数据库查询结果转换为 Todo 模型对象。
  /// 这是类型安全的关键，确保状态列表中只包含 Todo 对象。
  /// 
  /// 参数：
  ///   - map: 数据库查询结果的字典数据
  ///
  /// 返回：转换后的 Todo 对象实例
  @override
  Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);

  /// 添加一个新的待办事项
  ///
  /// 创建新的 Todo 对象并保存到数据库，同时更新应用状态。
  /// 这是用户创建新待办事项的主要入口点。
  /// 
  /// 参数:
  ///   - title: 待办事项的标题
  ///   - deadline: 待办事项的截止日期
  Future<void> addTodo(String title, DateTime deadline) async {
    final newTodo = Todo(title: title, deadline: deadline);
    await addTask(newTodo);
  }

  /// 切换指定待办事项的完成状态
  ///
  /// 查找指定 ID 的待办事项，切换其完成状态（完成/未完成），
  /// 并将变更保存到数据库。状态变更会自动触发 UI 更新。
  /// 
  /// 参数:
  ///   - id: 要切换完成状态的待办事项 ID
  Future<void> toggleTodo(String id) async {
    await toggleTask(id);
  }

  /// 删除指定的待办事项
  ///
  /// 从数据库和状态列表中移除指定 ID 的待办事项。
  /// 删除操作是不可逆的，执行前应确认用户意图。
  /// 
  /// 参数:
  ///   - id: 要删除的待办事项 ID
  Future<void> removeTodo(String id) async {
    await removeTask(id);
  }

  /// 更新指定待办事项的信息
  ///
  /// 修改待办事项的标题和截止日期，并将变更保存到数据库。
  /// 使用 copyWith 模式确保不可变性，符合函数式编程原则。
  /// 
  /// 参数:
  ///   - id: 要更新的待办事项 ID
  ///   - newTitle: 待办事项的新标题
  ///   - newDeadline: 待办事项的新截止日期
  Future<void> updateTodo(
      String id, String newTitle, DateTime newDeadline) async {
    final tmp = state.firstWhere((todo) => todo.id == id);
    tmp.update(newTitle, newDeadline);
    await super.updateTask(id, tmp);
  }
}

/// 待办事项状态提供者
///
/// 使用 StateNotifierProvider 创建全局可访问的待办事项状态。
/// UI 组件通过此提供者监听待办事项列表变化，实现响应式更新。
///
/// 返回值：包含 TodoListNotifier 实例和 List<Todo> 状态的提供者
final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});
