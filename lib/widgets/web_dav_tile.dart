import 'package:flutter/material.dart';

import 'package:memo/utils/func.dart';
import 'package:memo/utils/sync_helper.dart';

/// WebDAV配置瓦片组件
/// 
/// 用于在设置界面中提供WebDAV服务器配置功能的瓦片组件。
/// 该组件允许用户输入WebDAV服务器的URL、用户名和密码，并提供连接测试功能。
/// 配置信息会自动保存到本地存储，供同步功能使用。
/// 
/// 功能特点：
/// - WebDAV服务器配置界面
/// - 连接测试功能
/// - 配置信息自动保存
/// - 密码输入安全处理
/// - 用户友好的表单设计
/// - 操作状态反馈（成功/失败提示）
/// 
/// 使用示例：
/// ```dart
/// WebDavTile(
///   title: "WebDAV配置",
/// )
/// ```
/// 
/// 注意事项：
/// - 确保WebDAV服务器地址格式正确（如：http://example.com/webdav）
/// - 连接测试成功后会自动保存配置信息
/// - 密码信息会安全存储在本地
/// - 配置完成后可使用同步功能进行数据备份
class WebDavTile extends StatelessWidget {
  /// 瓦片标题文本
  /// 
  /// 显示在瓦片左侧的主要文本内容，用于描述功能名称。
  final String title;

  /// 构造函数
  /// 
  /// 创建一个WebDAV配置瓦片组件实例。
  /// 
  /// [key] 用于组件标识的可选键
  /// [title] 瓦片标题文本，必填参数
  const WebDavTile({super.key, required this.title});

  /// 构建组件UI
  /// 
  /// 构建WebDAV配置瓦片的用户界面，包括标题文本和配置按钮。
  /// 点击瓦片或图标按钮会弹出配置对话框，允许用户输入WebDAV服务器信息。
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回配置好的ListTile组件
  @override
  Widget build(BuildContext context) {
    // URL输入控制器
    final urlController = TextEditingController();
    // 用户名输入控制器
    final usernameController = TextEditingController();
    // 密码输入控制器
    final passwordController = TextEditingController();
    
    // WebDAV配置信息处理函数
    void webDavInfo() async {
      // 弹出对话框以输入WebDAV配置信息
      // 包括URL、账号、密码
      // 接收信息为info
      
      // 加载已保存的WebDAV配置信息
      final info = await SyncHelper.loadWebDavInfo();
      
      // 显示配置对话框
      await showDialog(
        context: context,
        builder: (context) {
          // 预填充已保存的配置信息
          urlController.text = info?.$1 ?? '';
          usernameController.text = info?.$2 ?? '';
          passwordController.text = info?.$3 ?? '';

          return AlertDialog(
            // 对话框标题
            title: Text(title),
            // 对话框内容
            content: Column(
              // 设置主轴方向尺寸为最小，避免对话框过大
              mainAxisSize: MainAxisSize.min,
              // 子组件列表
              children: [
                // URL输入框
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: '输入 WebDav url',
                    labelText: 'url',
                  ),
                ),
                // 用户名输入框
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: '输入 WebDav 账号',
                    labelText: '账号',
                  ),
                ),
                // 密码输入框
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: '输入 WebDav 密码',
                    labelText: '密码',
                  ),
                  // 设置为密码输入模式
                  obscureText: true,
                ),
                // 测试连接按钮
                ElevatedButton(
                  onPressed: () async {
                    // 获取输入的配置信息
                    final url = urlController.text;
                    final username = usernameController.text;
                    final password = passwordController.text;

                    // 测试WebDAV连接
                    var isConnect = await SyncHelper.testConnection(
                        url, username, password);
                    
                    // 显示连接结果
                    if (context.mounted) {
                      showSnackBar(
                        context,
                        isConnect,
                        '连接成功',
                        fail: '连接失败',
                        // 连接成功后的回调函数
                        onSuccess: () async {
                          // 保存WebDAV配置信息
                          await SyncHelper.saveWebDavInfo(
                              url, username, password);
                          // 关闭对话框
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
      // 显示瓦片标题
      title: Text(title),
      // 点击瓦片触发配置对话框
      onTap: () => webDavInfo(),
      // 右侧云端数据图标按钮
      trailing: IconButton(
        onPressed: () => webDavInfo(), 
        icon: Icon(Icons.cloud)
      ),
    );
  }
}
