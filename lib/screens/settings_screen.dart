import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/utils/sync_helper.dart';
import 'package:memo/widgets/exchange_tile.dart';
import 'package:memo/widgets/sync_tile.dart';
import 'package:memo/widgets/web_dav_tile.dart';

/// 设置页面
///
/// 提供应用程序的配置选项，包括主题切换、WebDAV同步配置和数据同步功能。
/// 该页面使用 Riverpod 进行状态管理，通过 ConsumerWidget 响应状态变化。
///
/// 功能特点：
/// - 支持切换应用主题（亮色/暗色模式）
/// - 配置 WebDAV 服务器信息，实现数据自动同步
/// - 提供数据上传和下载功能
/// - 显示应用版本信息和开发者信息
///
/// 状态管理：
/// - 使用 FutureBuilder 异步加载 WebDAV 配置信息
/// - 根据配置信息动态显示同步选项
class SettingsScreen extends ConsumerWidget {
  /// 构造函数
  /// 
  /// 创建一个设置页面实例。
  const SettingsScreen({super.key});

  /// 构建页面UI
  /// 
  /// 根据当前状态构建设置页面的用户界面。
  /// 
  /// 参数：
  ///   - context: 构建上下文，用于访问主题、导航等
  ///   - ref: WidgetRef 引用，用于访问 Riverpod 状态
  /// 
  /// 返回值：构建好的页面 Widget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 FutureBuilder 异步加载 WebDAV 配置信息
    return FutureBuilder<(String, String, String)?>(
      future: SyncHelper.loadWebDavInfo(), // 异步加载 WebDAV 配置
      builder: (context, snapshot) {
        // 判断是否已配置 WebDAV 信息
        final shouldShowSyncTile = snapshot.hasData && snapshot.data != null;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('设置'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 垂直方向两端对齐
              children: [
                // 上部分：功能选项
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 子组件水平方向拉伸
                  children: [
                    // 主题切换选项
                    ExchangeTile(title: '切换主题'),
                    // WebDAV 配置选项
                    WebDavTile(title: '配置WebDav自动同步'),
                    // 如果已配置 WebDAV，显示同步选项
                    if (shouldShowSyncTile)
                      SyncTile(
                        upTitle: '上传', // 上传按钮文本
                        downTitle: '下载', // 下载按钮文本
                        client: SyncHelper(
                          snapshot.data!.$1, // url
                          snapshot.data!.$2, // username
                          snapshot.data!.$3, // password
                        ),
                      ),
                  ],
                ),
                // 下部分：版本信息
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // 底部内边距
                  child: Column(
                    children: [
                      const Text('版本信息：1.1.2'), // 应用版本号
                      const Text('开发者：morningstart'), // 开发者信息
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
