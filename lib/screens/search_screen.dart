import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/prayer_store.dart';
import '../models/prayer_status.dart';
import '../widgets/category_pill.dart';
import '../widgets/prayer_item_card.dart';

class SearchScreen extends StatefulWidget {
  final PrayerStore store;

  const SearchScreen({super.key, required this.store});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _categoryFilter;
  PrayerStatus? _statusFilter;
  DateTime? _dateFilter;
  final TextEditingController _personCtrl = TextEditingController();

  @override
  void dispose() {
    _personCtrl.dispose();
    super.dispose();
  }

  bool get _hasFilter =>
      _categoryFilter != null ||
      _statusFilter != null ||
      _dateFilter != null ||
      _personCtrl.text.trim().isNotEmpty;

  void _clearFilters() {
    setState(() {
      _categoryFilter = null;
      _statusFilter = null;
      _dateFilter = null;
      _personCtrl.clear();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? now,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final person = _personCtrl.text.trim().toLowerCase();
    final dateKey = _dateFilter == null ? null : DateFormat('yyyy-MM-dd').format(_dateFilter!);

    final results = _hasFilter
        ? store.items.where((item) {
            final matchesCategory = _categoryFilter == null || item.categoryId == _categoryFilter;
            final matchesStatus = _statusFilter == null || item.status == _statusFilter;
            final matchesPerson =
                person.isEmpty || (item.personName?.toLowerCase().contains(person) ?? false);
            final matchesDate = dateKey == null ||
                item.createdAt.startsWith(dateKey) ||
                store.updatesForItem(item.id!).any((u) => u.date == dateKey);
            return matchesCategory && matchesStatus && matchesPerson && matchesDate;
          }).toList()
        : const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '검색',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_hasFilter)
                        TextButton(onPressed: _clearFilters, child: const Text('필터 초기화')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _personCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: '대상자별 검색',
                      hintText: '이름 또는 관계로 검색',
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: _personCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _personCtrl.clear()),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('유형별', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(
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
                  const SizedBox(height: 12),
                  Text('상태별', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: [
                      _FilterChip(
                        label: '전체',
                        selected: _statusFilter == null,
                        onTap: () => setState(() => _statusFilter = null),
                      ),
                      for (final s in PrayerStatus.values)
                        _FilterChip(
                          label: s.label,
                          selected: _statusFilter == s,
                          onTap: () => setState(() => _statusFilter = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('날짜별', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(dateKey ?? '날짜 선택'),
                      ),
                      if (_dateFilter != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dateFilter = null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: !_hasFilter
                  ? Center(
                      child: Text(
                        '검색 조건을 선택해주세요.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : results.isEmpty
                      ? Center(
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              PrayerItemCard(item: results[index], store: store),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

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
