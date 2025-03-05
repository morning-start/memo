import 'dart:io'; // 用于处理文件操作

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:memo/models/webdav_model.dart'; // 确保路径正确

// 定义一个StateNotifier来管理WebDavModel的状态
class WebDavNotifier extends StateNotifier<WebDavModel?> {
  WebDavNotifier() : super(null);

  // 设置WebDavModel
  void setWebDavModel(WebDavModel model) {
    state = model;
  }

  // 清空WebDavModel
  void clearWebDavModel() {
    state = null;
  }

  // 创建WebDavClient实例
  webdav.Client? getWebDavClient() {
    if (state == null) return null;
    return webdav.newClient(
      state!.uri,
      user: state!.name,
      password: state!.pwd,
    );
  }

  // TODO 上传文件
  Future<bool> uploadFile(String remotePath, File localFile) async {
    final client = getWebDavClient();
    if (client == null) {
      throw Exception("WebDAV client not initialized.");
    }

    return true;
  }

  // TODO 下载文件
  Future<bool> downloadFile(String remotePath, String localPath) async {
    final client = getWebDavClient();
    if (client == null) {
      throw Exception("WebDAV client not initialized.");
    }
    return true;
  }
}

// 定义Provider
final webDavProvider = StateNotifierProvider<WebDavNotifier, WebDavModel?>(
  (ref) => WebDavNotifier(),
);
