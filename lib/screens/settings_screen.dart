import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:memo/providers/theme_provider.dart';

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
              children: [
                ExchangeTile(title: '切换主题'),
                WebDavTile(title: 'WebDav配置'),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: Icon(
          ref.watch(themeModeProvider) == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
        onPressed: () {
          final themeModeNotifier = ref.read(themeModeProvider.notifier);
          themeModeNotifier.toggleTheme();
        },
      ),
    );
  }
}

class WebDavTile extends ConsumerWidget {
  final String title;

  const WebDavTile({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(title),
      onTap: () async {
        // 弹出 dialog 以输入 WebDav 配置信息
        // 包括 url，账号，密码
        // 接收信息为 res
        final {
          '0': String url,
          '1': String username,
          '2': String password,
        } = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text(title),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '输入 WebDav url',
                        labelText: 'url',
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '输入 WebDav 账号',
                        labelText: '账号',
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '输入 WebDav 密码',
                        labelText: '密码',
                      ),
                      obscureText: true,
                    )
                  ]));
            });
        var client = webdav.newClient(
          url,
          user: username,
          password: password,
          debug: true,
        );
        await client.ping();
      },
      // 云端数据的图标
      trailing: const Icon(Icons.cloud),
    );
  }
}
