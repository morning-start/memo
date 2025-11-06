import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/countdown_provider.dart';
import 'package:memo/providers/todo_provider.dart';
import 'package:memo/utils/func.dart';
import 'package:memo/utils/sync_helper.dart';

/// 同步瓦片组件
/// 
/// 用于在设置界面中提供数据上传和下载功能的瓦片组件。
/// 该组件使用WebDAV协议进行数据同步，支持实时进度显示和状态反馈。
/// 上传和下载操作完成后会自动刷新相关的数据提供者，确保UI显示最新数据。
/// 
/// 功能特点：
/// - 支持数据库文件的上传和下载
/// - 实时显示上传/下载进度
/// - 操作状态反馈（成功/失败提示）
/// - 防止重复操作的状态管理
/// - 同步完成后自动刷新数据
/// - 响应式UI设计，适配不同屏幕尺寸
/// 
/// 使用示例：
/// ```dart
/// SyncTile(
///   upTitle: "上传数据",
///   downTitle: "下载数据",
///   client: syncHelper,
/// )
/// ```
/// 
/// 注意事项：
/// - 需要确保SyncHelper客户端已正确配置
/// - 上传/下载过程中请勿关闭应用
/// - 下载操作会覆盖本地数据，请谨慎使用
/// - 组件依赖Riverpod状态管理，必须在Provider作用域内使用
class SyncTile extends ConsumerStatefulWidget {
  /// 上传瓦片标题
  /// 
  /// 显示在上传瓦片左侧的主要文本内容，用于描述上传功能。
  final String upTitle;
  
  /// 下载瓦片标题
  /// 
  /// 显示在下载瓦片左侧的主要文本内容，用于描述下载功能。
  final String downTitle;
  
  /// WebDAV同步客户端
  /// 
  /// 用于执行实际的上传和下载操作的SyncHelper实例。
  final SyncHelper client; // 传入的 WebDAV 客户端

  /// 构造函数
  /// 
  /// 创建一个同步瓦片组件实例。
  /// 
  /// [key] 用于组件标识的可选键
  /// [upTitle] 上传瓦片标题，必填参数
  /// [downTitle] 下载瓦片标题，必填参数
  /// [client] WebDAV同步客户端，必填参数
  const SyncTile({
    super.key,
    required this.upTitle,
    required this.downTitle,
    required this.client, // 添加 client 参数
  });

  @override
  _SyncTileState createState() => _SyncTileState();
}

/// 同步瓦片状态类
/// 
/// 管理同步瓦片的状态和UI更新，包括上传/下载进度和状态管理。
class _SyncTileState extends ConsumerState<SyncTile> {
  /// 上传进度值（0.0-1.0）
  /// 
  /// 表示当前上传操作的进度比例，0.0表示未开始，1.0表示完成。
  double _uploadProgress = 0.0; // 上传进度
  
  /// 下载进度值（0.0-1.0）
  /// 
  /// 表示当前下载操作的进度比例，0.0表示未开始，1.0表示完成。
  double _downloadProgress = 0.0; // 下载进度
  
  /// 上传操作状态
  /// 
  /// 表示当前是否正在执行上传操作，用于防止重复操作和UI状态显示。
  bool _isUploading = false; // 是否正在上传
  
  /// 下载操作状态
  /// 
  /// 表示当前是否正在执行下载操作，用于防止重复操作和UI状态显示。
  bool _isDownloading = false; // 是否正在下载

  /// 执行上传操作
  /// 
  /// 使用SyncHelper客户端上传数据库文件，并实时更新上传进度。
  /// 上传完成后显示操作结果，处理异常情况。
  /// 
  /// [context] 构建上下文，用于显示操作结果
  /// 
  /// 代码逻辑：
  /// 1. 检查是否正在上传，避免重复操作
  /// 2. 设置上传状态和重置进度
  /// 3. 调用SyncHelper的uploadDb方法执行上传
  /// 4. 通过onProgress回调更新上传进度
  /// 5. 显示上传结果（成功/失败）
  /// 6. 处理异常情况并重置上传状态
  Future<void> _upload(BuildContext context) async {
    // 避免重复上传
    if (_isUploading) return;
    
    // 设置上传状态和重置进度
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0; // 重置进度
    });

    try {
      // 执行上传操作
      bool res = await widget.client.uploadDb(
        // 上传进度回调
        onProgress: (sent, total) {
          // 检查组件是否仍然挂载
          if (mounted) {
            setState(() {
              _uploadProgress = sent / total; // 更新进度
            });
          }
        },
      );

      // 显示上传结果
      if (mounted) {
        showSnackBar(context, res, '上传成功', fail: '上传失败');
      }
    } catch (e) {
      // 显示上传错误
      if (mounted) {
        showSnackBar(context, false, '上传失败', fail: '上传过程中出现错误: $e');
      }
    } finally {
      // 重置上传状态
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// 执行下载操作
  /// 
  /// 使用SyncHelper客户端下载数据库文件，并实时更新下载进度。
  /// 下载完成后显示操作结果，刷新相关的数据提供者，处理异常情况。
  /// 
  /// [context] 构建上下文，用于显示操作结果
  /// 
  /// 代码逻辑：
  /// 1. 检查是否正在下载，避免重复操作
  /// 2. 设置下载状态和重置进度
  /// 3. 调用SyncHelper的downloadDb方法执行下载
  /// 4. 通过onProgress回调更新下载进度
  /// 5. 显示下载结果（成功/失败）
  /// 6. 刷新todo和countdown数据提供者
  /// 7. 处理异常情况并重置下载状态
  Future<void> _download(BuildContext context) async {
    // 避免重复下载
    if (_isDownloading) return;
    
    // 设置下载状态和重置进度
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0; // 重置进度
    });

    try {
      // 执行下载操作
      bool res = await widget.client.downloadDb(
        // 下载进度回调
        onProgress: (received, total) {
          // 检查组件是否仍然挂载
          if (mounted) {
            setState(() {
              _downloadProgress = received / total; // 更新进度
            });
          }
        },
      );

      // 显示下载结果并刷新数据
      if (mounted) {
        showSnackBar(context, res, '下载成功', fail: '下载失败');
        // 刷新todo列表
        ref.read(todoListProvider.notifier).refreshTasksAfterSync();
        // 刷新倒计时列表
        ref.read(countdownProvider.notifier).refreshTasksAfterSync();
      }
    } catch (e) {
      // 显示下载错误
      if (mounted) {
        showSnackBar(context, false, '下载失败', fail: '下载过程中出现错误: $e');
      }
    } finally {
      // 重置下载状态
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  /// 构建组件UI
  /// 
  /// 构建同步瓦片的用户界面，包含上传和下载两个ListTile，
  /// 每个瓦片包含标题、操作按钮和可选的进度条。
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回配置好的Column组件
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 上传瓦片
        ListTile(
          // 显示上传标题
          title: Text(widget.upTitle),
          // 点击瓦片触发上传
          onTap: () => _upload(context),
          // 右侧上传按钮
          trailing: IconButton(
            // 上传图标
            icon: const Icon(Icons.cloud_upload),
            // 点击按钮触发上传
            onPressed: () => _upload(context),
          ),
          // 上传进度条（仅在上传时显示）
          subtitle: _isUploading
              ? LinearProgressIndicator(
                  // 当前进度值
                  value: _uploadProgress,
                  // 进度条背景色
                  backgroundColor: Colors.grey[300],
                  // 进度条颜色
                  color: Colors.blue,
                )
              : null,
        ),
        // 下载瓦片
        ListTile(
          // 显示下载标题
          title: Text(widget.downTitle),
          // 点击瓦片触发下载
          onTap: () => _download(context),
          // 右侧下载按钮
          trailing: IconButton(
            // 下载图标
            icon: const Icon(Icons.cloud_download),
            // 点击按钮触发下载
            onPressed: () => _download(context),
          ),
          // 下载进度条（仅在下载时显示）
          subtitle: _isDownloading
              ? LinearProgressIndicator(
                  // 当前进度值
                  value: _downloadProgress,
                  // 进度条背景色
                  backgroundColor: Colors.grey[300],
                  // 进度条颜色
                  color: Colors.blue,
                )
              : null,
        ),
      ],
    );
  }
}
    