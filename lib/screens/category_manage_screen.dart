import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../widgets/category_form_sheet.dart';

class CategoryManageScreen extends StatelessWidget {
  final PrayerStore store;

  const CategoryManageScreen({super.key, required this.store});

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final jsonStr = await store.exportBackupJson();
      final now = DateTime.now();
      final fileName =
          'prayer_tree_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      final savedUri = await FilePicker.saveFile(
        dialogTitle: '기도 나무 백업 저장',
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(jsonStr)),
        mimeType: 'application/json',
      );
      if (savedUri == null) return;
      messenger.showSnackBar(const SnackBar(content: Text('백업 파일을 저장했습니다.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('백업 저장에 실패했습니다: $e')));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final file = await FilePicker.pickFile(
      dialogTitle: '백업 파일 선택',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업 복원'),
        content: const Text('현재 앱의 모든 데이터가 선택한 백업 파일 내용으로 교체됩니다. 계속할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('복원')),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final jsonStr = utf8.decode(await file.readAsBytes());
      await store.restoreBackupJson(jsonStr);
      messenger.showSnackBar(const SnackBar(content: Text('백업을 복원했습니다.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('백업 복원에 실패했습니다: $e')));
    }
  }

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
            const SizedBox(height: 28),
            Text(
              '데이터 백업',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '모든 기도 제목과 진행 기록을 파일로 저장하거나, 저장된 파일로 복원할 수 있습니다.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _exportBackup(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE6E2EE)),
                    ),
                    child: const Text('내보내기'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _importBackup(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE6E2EE)),
                    ),
                    child: const Text('가져오기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
