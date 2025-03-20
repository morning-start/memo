import 'package:flutter/material.dart';

import 'package:memo/utils/func.dart';
import 'package:memo/utils/sync_helper.dart';

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
