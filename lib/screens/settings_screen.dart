import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/utils/app_theme.dart';
import 'package:memo/utils/sync_helper.dart';
import 'package:memo/widgets/exchange_tile.dart';
import 'package:memo/widgets/sync_tile.dart';
import 'package:memo/widgets/web_dav_tile.dart';

/// 设置页面
///
/// 提供应用程序的配置选项，包括主题切换、WebDAV同步配置和数据同步功能。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<(String, String, String)?>(
      future: SyncHelper.loadWebDavInfo(),
      builder: (context, snapshot) {
        final shouldShowSyncTile = snapshot.hasData && snapshot.data != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('设置'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 功能选项
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg),
                    children: [
                      _sectionLabel(context, '外观'),
                      ExchangeTile(title: '切换主题'),
                      const SizedBox(height: AppSpacing.lg),
                      _sectionLabel(context, '数据同步'),
                      WebDavTile(title: '配置 WebDAV 自动同步'),
                      if (shouldShowSyncTile) ...[
                        const Divider(indent: 16, endIndent: 16),
                        SyncTile(
                          upTitle: '上传',
                          downTitle: '下载',
                          client: SyncHelper(
                            snapshot.data!.$1,
                            snapshot.data!.$2,
                            snapshot.data!.$3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 底部版本信息
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        '版本 1.2.0',
                        style: AppTypography.labelSmall(isDark),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'morningstart',
                        style: AppTypography.labelSmall(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.labelLarge(isDark).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
