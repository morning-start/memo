import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:memo/utils/db_helper.dart';

class WebDavHelper {
  static final String defaultDir = "/memo";
  final webdav.Client client;
  final String _dbPath = '$defaultDir/${DatabaseHelper.dbName}';

  WebDavHelper(String uri, String user, String pwd)
      : client = webdav.newClient(
          uri,
          user: user,
          password: pwd,
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

  Future<bool> uploadFile(String localFilePath, String remotePath) async {
    try {
      await client.writeFromFile(localFilePath, remotePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadFile(String remotePath, String localFilePath) async {
    try {
      await client.read2File(remotePath, localFilePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 上传数据库db
  Future<bool> uploadDb() async {
    return await uploadFile(await DatabaseHelper.getPath(), _dbPath);
  }

  // 下载数据库
  Future<bool> downloadDb() async {
    return await downloadFile(_dbPath, await DatabaseHelper.getPath());
  }
}
