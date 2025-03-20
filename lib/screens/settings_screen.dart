import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/utils/sync_helper.dart';
import 'package:memo/widgets/exchange_tile.dart';
import 'package:memo/widgets/sync_tile.dart';
import 'package:memo/widgets/web_dav_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<(String, String, String)?>(
      future: SyncHelper.loadWebDavInfo(),
      builder: (context, snapshot) {
        final shouldShowSyncTile = snapshot.hasData && snapshot.data != null;
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
                    if (shouldShowSyncTile)
                      SyncTile(
                          upTitle: '上传',
                          downTitle: '下载',
                          client: SyncHelper(
                            snapshot.data!.$1, // url
                            snapshot.data!.$2, // username
                            snapshot.data!.$3, // password
                          )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      const Text('版本信息：1.1.2'),
                      const Text('开发者：morningstart'),
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
