import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:memo/utils/db_helper.dart';

class SyncHelper {
  static final String defaultDir = "/memo";
  final webdav.Client client;
  final String _dbPath = '$defaultDir/${DatabaseHelper.dbName}';

  SyncHelper(String url, String user, String pwd)
      : client = webdav.newClient(
          url,
          user: user,
          password: pwd,
          debug: true
        );

  Future<bool> testConnection() async {
    try {
      await client.ping();
      await client.mkdir(defaultDir);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile(
    String localFilePath,
    String remotePath, {
    void Function(int, int)? onProgress,
  }) async {
    log( 'uploadFile: $localFilePath, $remotePath');
    try {
      await client.writeFromFile(localFilePath, remotePath,
          onProgress: onProgress);
      return true;
    } catch (e) {
       log('uploadFile error', error: e);
      return false;
    }
  }

  Future<bool> downloadFile(
    String remotePath,
    String localFilePath, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      await client.read2File(remotePath, localFilePath, onProgress: onProgress);
      return true;
    } catch (e) {
      log('downloadFile error', error: e);
      return false;
    }
  }

  // 上传数据库db
  Future<bool> uploadDb({
    void Function(int, int)? onProgress,
  }) async {
    return await uploadFile(await DatabaseHelper.getPath(), _dbPath,
        onProgress: onProgress);
  }

  // 下载数据库
  Future<bool> downloadDb({
    void Function(int, int)? onProgress,
  }) async {
    return await downloadFile(_dbPath, await DatabaseHelper.getPath(),
        onProgress: onProgress);
  }

  // 保存webdav信息
  static Future<bool> saveWebDavInfo(
      String url, String user, String pwd) async {
    // 获取SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // 保存信息
    prefs.setString('webdav_url', url);
    prefs.setString('webdav_user', user);
    prefs.setString('webdav_pwd', pwd);
    return true;
  }

  // 获取webdav信息
  static Future<(String, String, String)?> getWebDavInfo() async {
    // 获取SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // 获取信息
    final url = prefs.getString('webdav_url') ?? '';
    final user = prefs.getString('webdav_user') ?? '';
    final pwd = prefs.getString('webdav_pwd') ?? '';
    if (url.isEmpty || user.isEmpty || pwd.isEmpty) {
      return null;
    }
    return (url, user, pwd);
  }
}
