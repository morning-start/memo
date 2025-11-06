import 'package:flutter/material.dart';

/// 显示 SnackBar 提示消息的工具函数
///
/// 根据操作结果（成功/失败）显示相应的 SnackBar 消息，并支持执行相应的回调函数。
/// 此函数简化了在应用中显示操作结果反馈的流程，提供统一的用户体验。
///
/// 功能特点：
/// - 根据操作结果自动显示成功或失败消息
/// - 支持自定义成功和失败消息内容
/// - 提供可选的成功和失败回调函数
/// - 使用 ScaffoldMessenger 显示消息，确保在正确的上下文中显示
///
/// 使用示例：
/// ```dart
/// // 简单使用，只显示成功消息
/// showSnackBar(context, true, '保存成功');
/// 
/// // 显示失败消息
/// showSnackBar(context, false, '保存成功', fail: '保存失败');
/// 
/// // 带回调函数的使用
/// showSnackBar(
///   context, 
///   true, 
///   '保存成功',
///   onSuccess: () {
///     // 执行成功后的操作，如导航到其他页面
///     Navigator.pushReplacementNamed(context, '/home');
///   },
///   onFail: () {
///     // 执行失败后的操作，如重试或显示错误详情
///     _showErrorDialog();
///   },
/// );
/// ```
///
/// 参数：
///   - context - BuildContext，用于显示 SnackBar
///   - res - bool，操作结果，true 表示成功，false 表示失败
///   - success - String，操作成功时显示的消息
///   - fail - String?，可选参数，操作失败时显示的消息，如果为 null 则不显示失败消息
///   - onSuccess - VoidCallback?，可选参数，操作成功时执行的回调函数
///   - onFail - VoidCallback?，可选参数，操作失败时执行的回调函数
///
/// 注意事项：
/// - 确保传入的 context 是有效的 Scaffold 上下文
/// - 如果 fail 参数为 null 且操作失败，将不会显示任何消息
/// - 回调函数在 SnackBar 显示后立即执行，不是在 SnackBar 消失后执行
void showSnackBar(BuildContext context, bool res, String success,
    {String? fail, VoidCallback? onSuccess, VoidCallback? onFail}) {
  if (res) {
    // 操作成功，显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success),
      ),
    );
    onSuccess?.call(); // 执行成功回调
  } else if (fail != null) {
    // 操作失败且提供了失败消息，显示失败消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fail),
      ),
    );
    onFail?.call(); // 执行失败回调
  }
  // 如果操作失败但没有提供失败消息，则不显示任何内容
}
