import 'dart:developer';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' hide File;

import 'package:memo/utils/db_helper.dart';

/// WebDAV 同步辅助类
///
/// 提供应用程序数据与 WebDAV 服务器之间的同步功能，包括文件上传、下载
/// 和 WebDAV 配置信息的存储与读取。支持数据库文件的云端备份和恢复。
///
/// 功能特点：
/// - 支持与 WebDAV 服务器建立连接
/// - 提供文件上传和下载功能，支持进度回调
/// - 支持数据库文件的云端备份和恢复
/// - 提供 WebDAV 配置信息的本地存储
/// - 支持连接测试和验证
///
/// 使用示例：
/// ```dart
/// // 创建同步助手实例
/// final syncHelper = SyncHelper('https://example.com/dav', 'username', 'password');
/// 
/// // 上传数据库文件
/// bool uploadSuccess = await syncHelper.uploadDb(
///   onProgress: (sent, total) {
///     print('上传进度: ${(sent/total*100).toStringAsFixed(1)}%');
///   },
/// );
/// 
/// // 下载数据库文件
/// bool downloadSuccess = await syncHelper.downloadDb(
///   onProgress: (received, total) {
///     print('下载进度: ${(received/total*100).toStringAsFixed(1)}%');
///   },
/// );
/// 
/// // 测试连接
/// bool isConnected = await SyncHelper.testConnection(
///   'https://example.com/dav', 
///   'username', 
///   'password'
/// );
/// 
/// // 保存WebDAV配置
/// await SyncHelper.saveWebDavInfo('https://example.com/dav', 'username', 'password');
/// 
/// // 加载WebDAV配置
/// final config = await SyncHelper.loadWebDavInfo();
/// if (config != null) {
///   final (url, user, pwd) = config;
///   print('URL: $url, User: $user');
/// }
/// ```
///
/// 注意事项：
/// - 确保WebDAV服务器地址、用户名和密码正确
/// - 上传和下载操作可能会覆盖本地或远程文件，请谨慎使用
/// - 建议在上传前先备份本地数据
/// - 下载操作会替换当前数据库文件，建议先备份当前数据
class SyncHelper {
  /// 默认的远程目录名称
  static final String defaultDir = "memo";
  
  /// WebDAV 客户端实例
  final Client client;
  
  /// 数据库文件在远程服务器上的路径
  final String _dbPath = DatabaseHelper.dbName;

  /// 构造函数
  /// 
  /// 创建一个新的同步助手实例，初始化WebDAV客户端连接。
  /// 
  /// 参数：
  ///   - url - String，WebDAV服务器的基础URL
  ///   - user - String，WebDAV服务器的用户名
  ///   - pwd - String，WebDAV服务器的密码
  /// 
  /// 构造函数会自动处理URL格式，去除末尾的斜杠并添加默认目录。
  /// 
  /// 使用示例：
  /// ```dart
  /// // 创建同步助手实例
  /// final syncHelper = SyncHelper(
  ///   'https://example.com/dav/', 
  ///   'username', 
  ///   'password'
  /// );
  /// ```
  SyncHelper(String url, String user, String pwd)
      : client = newClient(
          '${url.replaceAll(RegExp(r'/$'), '')}/$defaultDir', // 去除末尾的斜杠并添加默认目录
          user: user,
          password: pwd,
          // debug: true, // 取消注释以启用调试日志
        );

  /// 测试WebDAV连接
  /// 
  /// 静态方法，用于测试给定的WebDAV服务器配置是否有效。
  /// 尝试连接服务器并创建默认目录，验证连接是否成功。
  /// 
  /// 参数：
  ///   - url - String，WebDAV服务器URL
  ///   - user - String，WebDAV服务器用户名
  ///   - password - String，WebDAV服务器密码
  /// 
  /// 返回值：Future<bool>，连接是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool isConnected = await SyncHelper.testConnection(
  ///   'https://example.com/dav', 
  ///   'username', 
  ///   'password'
  /// );
  /// 
  /// if (isConnected) {
  ///   print('连接成功');
  /// } else {
  ///   print('连接失败，请检查配置');
  /// }
  /// ```
  static Future<bool> testConnection(url, user, password) async {
    try {
      // 创建临时客户端
      var client = newClient(
        url,
        user: user,
        password: password,
      );
      // 测试连接
      await client.ping();
      // 尝试创建默认目录
      await client.mkdir(defaultDir);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 上传文件到WebDAV服务器
  /// 
  /// 将本地文件上传到WebDAV服务器的指定路径。
  /// 
  /// 参数：
  ///   - localFilePath - String，本地文件路径
  ///   - remotePath - String，远程服务器上的文件路径
  ///   - onProgress - Function(int, int)?，可选的上传进度回调函数，参数为(已发送字节数, 总字节数)
  /// 
  /// 返回值：Future<bool>，上传是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool success = await syncHelper.uploadFile(
  ///   '/path/to/local/file.txt',
  ///   'remote/path/file.txt',
  ///   onProgress: (sent, total) {
  ///     print('上传进度: ${(sent/total*100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<bool> uploadFile(
    String localFilePath,
    String remotePath, {
    void Function(int, int)? onProgress,
  }) async {
    // log('uploadFile: $localFilePath, $remotePath');
    try {
      // 创建本地文件对象
      File file = File(localFilePath);
      // 上传文件到远程服务器
      await client.write(remotePath, file.readAsBytesSync(), onProgress : onProgress);
      return true;
    } catch (e) {
      // 记录错误日志
      log('uploadFile error', error: e);
      return false;
    }
  }

  /// 从WebDAV服务器下载文件
  /// 
  /// 从WebDAV服务器的指定路径下载文件到本地。
  /// 
  /// 参数：
  ///   - remotePath - String，远程服务器上的文件路径
  ///   - localFilePath - String，本地文件保存路径
  ///   - onProgress - Function(int, int)?，可选的下载进度回调函数，参数为(已接收字节数, 总字节数)
  /// 
  /// 返回值：Future<bool>，下载是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool success = await syncHelper.downloadFile(
  ///   'remote/path/file.txt',
  ///   '/path/to/local/file.txt',
  ///   onProgress: (received, total) {
  ///     print('下载进度: ${(received/total*100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<bool> downloadFile(
    String remotePath,
    String localFilePath, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      // 从远程服务器下载文件到本地
      await client.read2File(remotePath, localFilePath, onProgress: onProgress);
      return true;
    } catch (e) {
      // 记录错误日志
      log('downloadFile error', error: e);
      return false;
    }
  }

  /// 上传数据库文件到WebDAV服务器
  /// 
  /// 将本地数据库文件上传到WebDAV服务器，用于数据备份。
  /// 
  /// 参数：
  ///   - onProgress - Function(int, int)?，可选的上传进度回调函数
  /// 
  /// 返回值：Future<bool>，上传是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool success = await syncHelper.uploadDb(
  ///   onProgress: (sent, total) {
  ///     print('数据库上传进度: ${(sent/total*100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// 
  /// if (success) {
  ///   print('数据库备份成功');
  /// } else {
  ///   print('数据库备份失败');
  /// }
  /// ```
  Future<bool> uploadDb({
    void Function(int, int)? onProgress,
  }) async {
    // 获取本地数据库文件路径并上传
    return await uploadFile(await DatabaseHelper.getPath(), _dbPath,
        onProgress: onProgress);
  }

  /// 从WebDAV服务器下载数据库文件
  /// 
  /// 从WebDAV服务器下载数据库文件到本地，用于数据恢复。
  /// 注意：此操作会替换当前的本地数据库文件。
  /// 
  /// 参数：
  ///   - onProgress - Function(int, int)?，可选的下载进度回调函数
  /// 
  /// 返回值：Future<bool>，下载是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool success = await syncHelper.downloadDb(
  ///   onProgress: (received, total) {
  ///     print('数据库下载进度: ${(received/total*100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// 
  /// if (success) {
  ///   print('数据库恢复成功');
  /// } else {
  ///   print('数据库恢复失败');
  /// }
  /// ```
  Future<bool> downloadDb({
    void Function(int, int)? onProgress,
  }) async {
    // 从远程服务器下载数据库文件到本地路径
    return await downloadFile(_dbPath, await DatabaseHelper.getPath(),
        onProgress: onProgress);
  }

  /// 保存WebDAV配置信息到本地存储
  /// 
  /// 将WebDAV服务器的URL、用户名和密码保存到SharedPreferences中。
  /// 
  /// 参数：
  ///   - url - String，WebDAV服务器URL
  ///   - user - String，WebDAV服务器用户名
  ///   - pwd - String，WebDAV服务器密码
  /// 
  /// 返回值：Future<bool>，保存是否成功
  /// 
  /// 使用示例：
  /// ```dart
  /// bool success = await SyncHelper.saveWebDavInfo(
  ///   'https://example.com/dav', 
  ///   'username', 
  ///   'password'
  /// );
  /// 
  /// if (success) {
  ///   print('配置保存成功');
  /// } else {
  ///   print('配置保存失败');
  /// }
  /// ```
  static Future<bool> saveWebDavInfo(
      String url, String user, String pwd) async {
    // 获取SharedPreferences实例
    final prefs = await SharedPreferences.getInstance();
    // 保存WebDAV配置信息
    prefs.setString('webdav_url', url);
    prefs.setString('webdav_user', user);
    prefs.setString('webdav_pwd', pwd);
    return true;
  }

  /// 从本地存储加载WebDAV配置信息
  /// 
  /// 从SharedPreferences中读取之前保存的WebDAV服务器配置。
  /// 
  /// 返回值：Future<(String, String, String)?>，配置信息的元组，包含(URL, 用户名, 密码)，如果配置不存在则返回null
  /// 
  /// 使用示例：
  /// ```dart
  /// final config = await SyncHelper.loadWebDavInfo();
  /// if (config != null) {
  ///   final (url, user, pwd) = config;
  ///   print('URL: $url, User: $user');
  ///   
  ///   // 使用配置创建同步助手
  ///   final syncHelper = SyncHelper(url, user, pwd);
  /// } else {
  ///   print('未找到WebDAV配置');
  /// }
  /// ```
  static Future<(String, String, String)?> loadWebDavInfo() async {
    // 获取SharedPreferences实例
    final prefs = await SharedPreferences.getInstance();
    // 读取WebDAV配置信息
    final url = prefs.getString('webdav_url') ?? '';
    final user = prefs.getString('webdav_user') ?? '';
    final pwd = prefs.getString('webdav_pwd') ?? '';
    
    // 检查配置是否完整
    if (url.isEmpty || user.isEmpty || pwd.isEmpty) {
      return null;
    }
    
    // 返回配置信息元组
    return (url, user, pwd);
  }
}
