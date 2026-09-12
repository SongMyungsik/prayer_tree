import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../widgets/category_form_sheet.dart';

class CategoryManageScreen extends StatelessWidget {
  final PrayerStore store;

  const CategoryManageScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '기도 제목을 분류할 카테고리를 관리합니다.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            for (final c in store.categories)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: Color(c.color), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Text(
                        '${store.itemCountForCategory(c.id!)}개',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final result = await showCategoryFormSheet(context, initial: c);
                          if (result != null) {
                            await store.updateCategory(c.id!, result.name, result.color);
                          }
                        },
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final count = store.itemCountForCategory(c.id!);
                          final message = count > 0
                              ? '이 카테고리에 속한 기도 제목 $count개와 진행 기록도 함께 삭제됩니다. 계속할까요?'
                              : '이 카테고리를 삭제할까요?';
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('카테고리 삭제'),
                              content: Text(message),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await store.deleteCategory(c.id!);
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFC0526A)),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                ),
              ),
            OutlinedButton(
              onPressed: () async {
                final result = await showCategoryFormSheet(context);
                if (result != null) {
                  await store.addCategory(result.name, result.color);
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE6E2EE)),
              ),
              child: const Text('+ 카테고리 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
