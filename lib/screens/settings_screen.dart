import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/theme_provider.dart';
import 'package:memo/utils/func.dart';
import 'package:memo/utils/sync_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // DatabaseHelper.close();
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExchangeTile(title: '切换主题'),
                WebDavTile(title: '配置WebDav自动同步'),
                UploadDownloadTile(upTitle: '上传', downTitle: '下载'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  const Text('版本信息：1.1.0'),
                  const Text('开发者：morningstart'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UploadDownloadTile extends StatefulWidget {
  final String upTitle;
  final String downTitle;

  const UploadDownloadTile({
    super.key,
    required this.upTitle,
    required this.downTitle,
  });

  @override
  _UploadDownloadTileState createState() => _UploadDownloadTileState();
}

class _UploadDownloadTileState extends State<UploadDownloadTile> {
  double _uploadProgress = 0.0; // 上传进度
  double _downloadProgress = 0.0; // 下载进度
  bool _isUploading = false; // 是否正在上传
  bool _isDownloading = false; // 是否正在下载

  // 上传
  Future<void> _upload(BuildContext context, SyncHelper client) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0; // 重置进度
    });

    bool res = await client.uploadDb(
      onProgress: (sent, total) {
        setState(() {
          _uploadProgress = sent / total; // 更新进度
        });
      },
    );

    setState(() {
      _isUploading = false;
    });

    if (context.mounted) showSnackBar(context, res, '上传成功', fail: '上传失败');
  }

  // 下载
  Future<void> _download(BuildContext context, SyncHelper client) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0; // 重置进度
    });

    bool res = await client.downloadDb(
      onProgress: (received, total) {
        setState(() {
          _downloadProgress = received / total; // 更新进度
        });
      },
    );

    setState(() {
      _isDownloading = false;
    });

    if (context.mounted) showSnackBar(context, res, '下载成功', fail: '下载失败');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SyncHelper.loadWebDavInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final webDavInfo = snapshot.data;
          bool isVisible = webDavInfo != null;
          if (isVisible) {
            final url = webDavInfo.$1;
            final username = webDavInfo.$2;
            final password = webDavInfo.$3;
            var client = SyncHelper(url, username, password);

            return Column(
              children: [
                ListTile(
                  title: Text(widget.upTitle),
                  onTap: () async => await _upload(context, client),
                  trailing: IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () async => await _upload(context, client),
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
                  onTap: () async => await _download(context, client),
                  trailing: IconButton(
                    icon: const Icon(Icons.cloud_download),
                    onPressed: () async => await _download(context, client),
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
        return Container(); // 或者其他占位符
      },
    );
  }
}

class ExchangeTile extends ConsumerWidget {
  final String title;

  const ExchangeTile({super.key, required this.title});

  // change
  void changeTheme(WidgetRef ref) {
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    themeModeNotifier.toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(title),
      onTap: () => changeTheme(ref),
      trailing: IconButton(
        icon: Icon(
          ref.watch(themeModeProvider) == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
        onPressed: () => changeTheme(ref),
      ),
    );
  }
}

class WebDavTile extends StatelessWidget {
  final String title;

  const WebDavTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final urlController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    // bool isConnect = false;
    void webDavInfo() async {
      // 弹出 dialog 以输入 WebDav 配置信息
      // 包括 url，账号，密码
      // 接收信息为 res
      final info = await SyncHelper.loadWebDavInfo();
      await showDialog(
          context: context,
          builder: (context) {
            urlController.text = info?.$1 ?? '';
            usernameController.text = info?.$2 ?? '';
            passwordController.text = info?.$3 ?? '';

            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: '输入 WebDav url',
                      labelText: 'url',
                    ),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: '输入 WebDav 账号',
                      labelText: '账号',
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '输入 WebDav 密码',
                      labelText: '密码',
                    ),
                    obscureText: true,
                  ),
                  // 测试连接按钮
                  ElevatedButton(
                    onPressed: () async {
                      final url = urlController.text;
                      final username = usernameController.text;
                      final password = passwordController.text;

                      var isConnect = await SyncHelper.testConnection(
                          url, username, password);
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          isConnect,
                          '连接成功',
                          fail: '连接失败',
                          onSuccess: () async {
                            await SyncHelper.saveWebDavInfo(
                                url, username, password);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      }
                    },
                    child: Text('测试连接并保存'),
                  ),
                ],
              ),
            );
          });
    }

    return ListTile(
      title: Text(title),
      onTap: () => webDavInfo(),
      // 云端数据的图标
      trailing:
          IconButton(onPressed: () => webDavInfo(), icon: Icon(Icons.cloud)),
    );
  }
}
