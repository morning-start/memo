import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _toggleTheme() {
      final themeModeNotifier = ref.read(themeModeProvider.notifier);
      themeModeNotifier.toggleTheme();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              title: const Text('切换主题'),
              trailing: IconButton(
                icon: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: _toggleTheme,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  const Text('版本信息：1.0.0'),
                  const Text('开发者：morningstart'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
