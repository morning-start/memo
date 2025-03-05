import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDavNotifier extends StateNotifier<webdav.Client> {
  static final String defaultDir = "memo";
  WebDavNotifier(String uri, String user, String pwd)
      : super(webdav.newClient(
          '$uri/$defaultDir',
          user: user,
          password: pwd,
        ));

  Future<bool> testConnection() async {
    try {
      await state.ping();
      await state.mkdir(defaultDir);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile(String remotePath, String localFilePath) async {
    try {
      await state.writeFromFile(localFilePath, remotePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadFile(String remotePath, String localPath) async {
    try {
      await state.read2File(remotePath, localPath);
      return true;
    } catch (e) {
      return false;
    }
  }
  // 上传数据库db
  // 下载数据库
  // 上传配置
  // 下载配置

}

// 定义Provider
final webDavProvider = StateNotifierProvider<WebDavNotifier, webdav.Client>(
  (ref) => throw Exception(
      'WebDavNotifier requires URI, user, and password arguments.'),
);

// 使用时需要提供参数
final webDavProviderWithArgs =
    Provider.family<WebDavNotifier, (String, String, String)>(
  (ref, args) => WebDavNotifier(args.$1, args.$2, args.$3),
);
