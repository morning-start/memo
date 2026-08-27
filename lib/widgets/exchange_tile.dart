import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/theme_provider.dart';

/// 主题切换瓦片组件
///
/// 用于在设置界面中提供主题切换功能的瓦片组件，支持深色模式和浅色模式之间的切换。
class ExchangeTile extends ConsumerWidget {
  final String title;

  const ExchangeTile({super.key, required this.title});

  void changeTheme(WidgetRef ref) {
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    themeModeNotifier.toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(title),
      onTap: () => changeTheme(ref),
      trailing: IconButton(
        icon: Icon(
          ref.watch(themeModeProvider) == ThemeMode.dark
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
        ),
        onPressed: () => changeTheme(ref),
      ),
    );
  }
}
