import 'package:flutter/material.dart';

/// 信息按钮组件
/// 
/// 用于显示带有标签和反馈文本的自定义按钮组件。
/// 该组件采用ElevatedButton作为基础，内部使用Row布局显示标签文本和反馈文本。
/// 适用于需要同时显示操作名称和操作结果的场景，如保存按钮显示"保存 成功"。
/// 
/// 功能特点：
/// - 自定义按钮标签和反馈文本
/// - 水平布局显示标签和反馈信息
/// - 自适应内容宽度
/// - 支持自定义点击回调
/// - Material Design风格的凸起按钮
/// 
/// 使用示例：
/// ```dart
/// InfoButton(
///   label: "保存",
///   feedback: "成功",
///   onPressed: () {
///     // 执行保存操作
///   },
/// )
/// ```
/// 
/// 注意事项：
/// - 反馈文本应简洁明了，避免过长影响UI布局
/// - 按钮宽度会根据内容自适应，注意在有限空间内的使用
/// - 确保onPressed回调函数不为null，否则按钮将被禁用
class InfoButton extends StatelessWidget {
  /// 按钮标签文本
  /// 
  /// 显示在按钮左侧的主要文本内容，用于描述按钮的操作功能。
  final String label;
  
  /// 按钮反馈文本
  /// 
  /// 显示在按钮右侧的辅助文本内容，用于显示操作结果或状态信息。
  final String feedback;
  
  /// 按钮点击回调
  /// 
  /// 当用户点击按钮时调用的函数，用于处理按钮的点击事件。
  final VoidCallback onPressed;

  /// 构造函数
  /// 
  /// 创建一个信息按钮组件实例。
  /// 
  /// [key] 用于组件标识的可选键
  /// [onPressed] 按钮点击回调函数，必填参数
  /// [label] 按钮标签文本，必填参数
  /// [feedback] 按钮反馈文本，必填参数
  const InfoButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.feedback,
  });

  /// 构建组件UI
  /// 
  /// 构建信息按钮的用户界面，使用ElevatedButton作为基础，
  /// 内部使用Row布局水平排列标签文本和反馈文本。
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回配置好的ElevatedButton组件
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // 设置按钮点击回调
      onPressed: onPressed,
      // 按钮内容使用水平布局
      child: Row(
        // 设置主轴方向尺寸为最小，使按钮宽度自适应内容
        mainAxisSize: MainAxisSize.min,
        // 子组件列表
        children: [
          // 显示标签文本
          Text(label),
          // 标签和反馈之间的间距
          const SizedBox(width: 8),
          // 显示反馈文本
          Text(feedback),
        ],
      ),
    );
  }
}