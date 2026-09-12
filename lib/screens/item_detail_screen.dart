import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../models/prayer_status.dart';
import '../widgets/category_pill.dart';
import '../widgets/prayer_item_form_sheet.dart';
import '../widgets/status_badge.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  final PrayerStore store;

  const ItemDetailScreen({super.key, required this.itemId, required this.store});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _contentCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  String get _dateLabel =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final item = store.itemById(widget.itemId);
        if (item == null) {
          return const Scaffold(body: Center(child: Text('삭제된 항목입니다.')));
        }
        final category = store.categoryById(item.categoryId);
        final itemUpdates = store.updatesForItem(item.id!);

        return Scaffold(
          appBar: AppBar(title: const Text('기도 제목')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                                if (item.personName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(item.personName!, style: TextStyle(color: Colors.grey[600])),
                                ],
                              ],
                            ),
                          ),
                          if (category != null)
                            CategoryPill(name: category.name, color: Color(category.color)),
                        ],
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 10),
                        Text(item.description!),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: PrayerStatus.values.map((s) {
                          final selected = item.status == s;
                          return GestureDetector(
                            onTap: () => store.setItemStatus(item.id!, s),
                            child: selected
                                ? StatusBadge(status: s)
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE6E2EE)),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      s.label,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              final result = await showPrayerItemFormSheet(
                                context,
                                categories: store.categories,
                                initial: item,
                              );
                              if (result != null) {
                                await store.updateItem(
                                  item.id!,
                                  categoryId: result.categoryId,
                                  title: result.title,
                                  personName: result.personName,
                                  description: result.description,
                                );
                              }
                            },
                            child: const Text('수정'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('삭제하시겠습니까?'),
                                  content: const Text('이 기도 제목과 모든 진행 기록이 함께 삭제됩니다.'),
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
                                await store.deleteItem(item.id!);
                                if (context.mounted) Navigator.of(context).pop();
                              }
                            },
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFC0526A)),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('진행 기록', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: '날짜'),
                          child: Text(_dateLabel),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _contentCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: '오늘의 기도 진행 상황을 기록해주세요'),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            final content = _contentCtrl.text.trim();
                            if (content.isEmpty) return;
                            await store.addProgressUpdate(item.id!, _dateLabel, content);
                            _contentCtrl.clear();
                          },
                          child: const Text('기록 추가'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (itemUpdates.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('아직 기록이 없습니다.', style: TextStyle(color: Colors.grey[500])),
                  ),
                )
              else
                ...itemUpdates.map(
                  (u) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(u.content),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => store.deleteProgressUpdate(u.id!),
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.grey,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
