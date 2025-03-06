import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/theme_provider.dart';
import 'package:memo/utils/sync_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  const Text('版本信息：1.0.0'),
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
    void webDavInfo() async {
      // 弹出 dialog 以输入 WebDav 配置信息
      // 包括 url，账号，密码
      // 接收信息为 res
      await showDialog(
          context: context,
          builder: (context) {
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

                      var client = SyncHelper(url, username, password);
                      var isConnect = await client.testConnection();
                      if (isConnect) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('连接成功')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('连接失败')),
                        );
                      }
                    },
                    child: Text('测试连接'),
                  ),
                  // 保存按钮
                  ElevatedButton(
                    onPressed: () async {
                      // 处理保存逻辑
                      final url = urlController.text;
                      final user = usernameController.text;
                      final pwd = passwordController.text;
                      await SyncHelper.saveWebDavInfo(url, user, pwd);
                      Navigator.pop(context);
                    },
                    child: Text('保存'),
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
