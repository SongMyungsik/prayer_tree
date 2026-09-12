import 'package:flutter/material.dart';

import '../models/prayer_category.dart';

const List<Color> presetColors = [
  Color(0xFFE0708A),
  Color(0xFF5B8FD6),
  Color(0xFF5AAB8F),
  Color(0xFFC98FD6),
  Color(0xFFD69A5B),
  Color(0xFF8A8794),
  Color(0xFFD65B5B),
  Color(0xFF5BC0C9),
];

class CategoryFormResult {
  final String name;
  final int color;

  CategoryFormResult({required this.name, required this.color});
}

Future<CategoryFormResult?> showCategoryFormSheet(
  BuildContext context, {
  PrayerCategory? initial,
}) {
  return showModalBottomSheet<CategoryFormResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CategoryFormSheet(initial: initial),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  final PrayerCategory? initial;

  const _CategoryFormSheet({this.initial});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _color = widget.initial != null ? Color(widget.initial!.color) : presetColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? '카테고리 수정' : '카테고리 추가',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: '이름 *', hintText: '예: 선교사'),
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('색상')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: presetColors.map((c) {
              final selected = c.toARGB32() == _color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.black26, width: 2) : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.of(context).pop(CategoryFormResult(name: name, color: _color.toARGB32()));
            },
            child: Text(isEdit ? '수정 완료' : '추가하기'),
          ),
        ],
      ),
    );
  }
}
