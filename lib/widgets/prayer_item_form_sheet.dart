import 'package:flutter/material.dart';

import '../models/prayer_category.dart';
import '../models/prayer_item.dart';

class PrayerItemFormResult {
  final int categoryId;
  final String title;
  final String? personName;

  PrayerItemFormResult({
    required this.categoryId,
    required this.title,
    this.personName,
  });
}

Future<PrayerItemFormResult?> showPrayerItemFormSheet(
  BuildContext context, {
  required List<PrayerCategory> categories,
  PrayerItem? initial,
  int? initialCategoryId,
}) {
  return showModalBottomSheet<PrayerItemFormResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PrayerItemFormSheet(
      categories: categories,
      initial: initial,
      initialCategoryId: initialCategoryId,
    ),
  );
}

class _PrayerItemFormSheet extends StatefulWidget {
  final List<PrayerCategory> categories;
  final PrayerItem? initial;
  final int? initialCategoryId;

  const _PrayerItemFormSheet({required this.categories, this.initial, this.initialCategoryId});

  @override
  State<_PrayerItemFormSheet> createState() => _PrayerItemFormSheetState();
}

class _PrayerItemFormSheetState extends State<_PrayerItemFormSheet> {
  late int _categoryId;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _personCtrl;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initial?.categoryId ?? widget.initialCategoryId ?? widget.categories.first.id!;
    _contentCtrl = TextEditingController(text: _initialContent(widget.initial));
    _personCtrl = TextEditingController(text: widget.initial?.personName ?? '');
  }

  String _initialContent(PrayerItem? initial) {
    if (initial == null) return '';
    final description = initial.description?.trim();
    if (description == null || description.isEmpty) return initial.title;
    return '${initial.title}\n$description';
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _personCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? '기도 제목 수정' : '기도 제목 추가',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: '유형'),
              items: widget.categories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _personCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '이름 (선택)', hintText: '이름 또는 관계'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '내용 *',
                hintText: '예: OO 집사님 건강 회복을 위해 기도해주세요',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                final content = _contentCtrl.text.trim();
                if (content.isEmpty) return;
                Navigator.of(context).pop(
                  PrayerItemFormResult(
                    categoryId: _categoryId,
                    title: content,
                    personName: _personCtrl.text.trim().isEmpty ? null : _personCtrl.text.trim(),
                  ),
                );
              },
              child: Text(isEdit ? '수정 완료' : '추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
