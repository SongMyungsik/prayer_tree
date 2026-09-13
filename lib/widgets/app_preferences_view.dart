import 'package:flutter/material.dart';

import '../data/app_settings.dart';

class AppPreferencesView extends StatelessWidget {
  final AppSettings settings;

  const AppPreferencesView({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('화면 모드', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('시스템'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('라이트'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('다크'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) => settings.setThemeMode(selection.first),
            ),
            const SizedBox(height: 28),
            Text('앱 색상', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '앱바와 하단 네비게이션에 반영됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final color in seedColorPresets)
                  GestureDetector(
                    onTap: () => settings.setSeedColor(color),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: settings.seedColor.toARGB32() == color.toARGB32()
                            ? Border.all(color: Colors.black87, width: 3)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: settings.seedColor.toARGB32() == color.toARGB32()
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text('비밀번호', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _showChangePasswordDialog(context, settings),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                side: const BorderSide(color: Color(0xFFE6E2EE)),
              ),
              child: const Text('비밀번호 변경'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, AppSettings settings) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submit() async {
              if (currentCtrl.text != settings.password) {
                setState(() => error = '현재 비밀번호가 올바르지 않습니다.');
                return;
              }
              if (newCtrl.text.length != 4) {
                setState(() => error = '새 비밀번호는 4자리 숫자여야 합니다.');
                return;
              }
              if (newCtrl.text != confirmCtrl.text) {
                setState(() => error = '새 비밀번호가 서로 일치하지 않습니다.');
                return;
              }
              await settings.setPassword(newCtrl.text);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            }

            return AlertDialog(
              title: const Text('비밀번호 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(labelText: '현재 비밀번호'),
                  ),
                  TextField(
                    controller: newCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(labelText: '새 비밀번호'),
                  ),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(labelText: '새 비밀번호 확인', errorText: error),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                FilledButton(onPressed: submit, child: const Text('변경')),
              ],
            );
          },
        );
      },
    );
  }
}
