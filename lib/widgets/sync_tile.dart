import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/countdown_provider.dart';
import 'package:memo/providers/todo_provider.dart';
import 'package:memo/utils/func.dart';
import 'package:memo/utils/sync_helper.dart';

class SyncTile extends ConsumerStatefulWidget {
  final String upTitle;
  final String downTitle;
  final SyncHelper client; // 传入的 WebDAV 客户端

  const SyncTile({
    super.key,
    required this.upTitle,
    required this.downTitle,
    required this.client, // 添加 client 参数
  });

  @override
  _SyncTileState createState() => _SyncTileState();
}

class _SyncTileState extends ConsumerState<SyncTile> {
  double _uploadProgress = 0.0; // 上传进度
  double _downloadProgress = 0.0; // 下载进度
  bool _isUploading = false; // 是否正在上传
  bool _isDownloading = false; // 是否正在下载

  // 上传
  Future<void> _upload(BuildContext context) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0; // 重置进度
    });

    bool res = await widget.client.uploadDb(
      onProgress: (sent, total) {
        if (mounted) {
          setState(() {
            _uploadProgress = sent / total; // 更新进度
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      showSnackBar(context, res, '上传成功', fail: '上传失败');
    }
  }

  // 下载
  Future<void> _download(BuildContext context) async {
    final ref = this.ref; // 获取 ref
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0; // 重置进度
    });

    bool res = await widget.client.downloadDb(
      onProgress: (received, total) {
        if (mounted) {
          setState(() {
            _downloadProgress = received / total; // 更新进度
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });
      showSnackBar(context, res, '下载成功', fail: '下载失败');
      // 在这里你可以使用 ref 调用其他 provider
      // 例如：ref.read(someProvider.notifier).doSomething();
      ref.read(todoListProvider.notifier).refreshTasksAfterSync();
      ref.read(countdownProvider.notifier).refreshTasksAfterSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.upTitle),
          onTap: () async => await _upload(context),
          trailing: IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async => await _upload(context),
          ),
          subtitle: _isUploading
              ? LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                )
              : null,
        ),
        ListTile(
          title: Text(widget.downTitle),
          onTap: () async => await _download(context),
          trailing: IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () async => await _download(context),
          ),
          subtitle: _isDownloading
              ? LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                )
              : null,
        ),
      ],
    );
  }
}    