import 'package:flutter/material.dart';

import '../models/prayer_category.dart';
import '../models/prayer_item.dart';

class PrayerItemFormResult {
  final int categoryId;
  final String title;
  final String? personName;
  final String? description;

  PrayerItemFormResult({
    required this.categoryId,
    required this.title,
    this.personName,
    this.description,
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
  late final TextEditingController _titleCtrl;
  late final TextEditingController _personCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initial?.categoryId ?? widget.initialCategoryId ?? widget.categories.first.id!;
    _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
    _personCtrl = TextEditingController(text: widget.initial?.personName ?? '');
    _descCtrl = TextEditingController(text: widget.initial?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _personCtrl.dispose();
    _descCtrl.dispose();
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
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '제목 *', hintText: '예: OO 집사님 건강 회복'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _personCtrl,
              decoration: const InputDecoration(labelText: '대상자 (선택)', hintText: '이름 또는 관계'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '설명 (선택)', hintText: '기도 배경, 상황 등을 적어주세요'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                final title = _titleCtrl.text.trim();
                if (title.isEmpty) return;
                Navigator.of(context).pop(
                  PrayerItemFormResult(
                    categoryId: _categoryId,
                    title: title,
                    personName: _personCtrl.text.trim().isEmpty ? null : _personCtrl.text.trim(),
                    description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
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
