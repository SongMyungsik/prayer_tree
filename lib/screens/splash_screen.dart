import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '중보기도관리앱',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '기도나무',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prayer Tree',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.12),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🙏', style: TextStyle(fontSize: 64)),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeShell()),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('시작하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Prayer_Tree Ver.1.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
