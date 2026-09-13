import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/prayer_store.dart';
import '../models/prayer_status.dart';
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

  bool get _hasActiveFilter =>
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

    final results = store.items.where((item) {
      final matchesCategory = _categoryFilter == null || item.categoryId == _categoryFilter;
      final matchesStatus = _statusFilter == null || item.status == _statusFilter;
      final matchesPerson =
          person.isEmpty || (item.personName?.toLowerCase().contains(person) ?? false);
      final matchesDate = dateKey == null ||
          item.createdAt.startsWith(dateKey) ||
          store.updatesForItem(item.id!).any((u) => u.date == dateKey);
      return matchesCategory && matchesStatus && matchesPerson && matchesDate;
    }).toList();

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
                      if (_hasActiveFilter)
                        TextButton(onPressed: _clearFilters, child: const Text('필터 초기화')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _personCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: '이름 검색',
                            prefixIcon: const Icon(Icons.person_outline),
                            suffixIcon: _personCtrl.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() => _personCtrl.clear()),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '날짜 선택',
                              prefixIcon: const Icon(Icons.calendar_today, size: 18),
                              suffixIcon: _dateFilter == null
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () => setState(() => _dateFilter = null),
                                    ),
                            ),
                            child: Text(dateKey ?? '', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: _categoryFilter,
                          decoration: const InputDecoration(labelText: '유형별'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('전체')),
                            for (final c in store.categories)
                              DropdownMenuItem(value: c.id, child: Text(c.name)),
                          ],
                          onChanged: (v) => setState(() => _categoryFilter = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<PrayerStatus?>(
                          initialValue: _statusFilter,
                          decoration: const InputDecoration(labelText: '상태별'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('전체')),
                            for (final s in PrayerStatus.values)
                              DropdownMenuItem(value: s, child: Text(s.label)),
                          ],
                          onChanged: (v) => setState(() => _statusFilter = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: results.isEmpty
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

