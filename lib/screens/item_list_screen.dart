import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../models/prayer_status.dart';
import '../widgets/category_pill.dart';
import '../widgets/prayer_item_card.dart';
import '../widgets/prayer_item_form_sheet.dart';

class ItemListScreen extends StatefulWidget {
  final PrayerStore store;

  const ItemListScreen({super.key, required this.store});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  int? _categoryFilter;
  PrayerStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final filtered = store.items.where((item) {
      final matchesCategory = _categoryFilter == null || item.categoryId == _categoryFilter;
      final matchesStatus = _statusFilter == null || item.status == _statusFilter;
      return matchesCategory && matchesStatus;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _categoryFilter = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryFilter == null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(color: const Color(0xFFE6E2EE)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _categoryFilter == null ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  for (final c in store.categories)
                    GestureDetector(
                      onTap: () => setState(() => _categoryFilter = c.id),
                      child: CategoryPill(
                        name: c.name,
                        color: Color(c.color),
                        selected: _categoryFilter == c.id,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 4,
                children: [
                  _StatusFilterChip(
                    label: '전체 상태',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  ),
                  for (final s in PrayerStatus.values)
                    _StatusFilterChip(
                      label: s.label,
                      selected: _statusFilter == s,
                      onTap: () => setState(() => _statusFilter = s),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '해당하는 기도 제목이 없습니다.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => PrayerItemCard(
                        item: filtered[index],
                        store: store,
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showPrayerItemFormSheet(
            context,
            categories: store.categories,
            initialCategoryId: _categoryFilter,
          );
          if (result != null) {
            await store.addItem(
              categoryId: result.categoryId,
              title: result.title,
              personName: result.personName,
              description: result.description,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

