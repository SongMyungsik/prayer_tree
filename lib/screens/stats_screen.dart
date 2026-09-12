import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../models/prayer_status.dart';

class StatsScreen extends StatelessWidget {
  final PrayerStore store;

  const StatsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final items = store.items;

    final categoryCounts = <int, int>{};
    for (final i in items) {
      categoryCounts[i.categoryId] = (categoryCounts[i.categoryId] ?? 0) + 1;
    }
    final categoryRows = store.categories
        .map((c) => MapEntry(c.name, categoryCounts[c.id] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final personCounts = <String, int>{};
    for (final i in items) {
      final p = i.personName?.trim();
      if (p != null && p.isNotEmpty) {
        personCounts[p] = (personCounts[p] ?? 0) + 1;
      }
    }
    final personRows = personCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final statusCounts = <PrayerStatus, int>{};
    for (final i in items) {
      statusCounts[i.status] = (statusCounts[i.status] ?? 0) + 1;
    }
    final statusRows =
        PrayerStatus.values.map((s) => MapEntry(s.label, statusCounts[s] ?? 0)).toList();

    final monthCounts = <String, int>{};
    for (final i in items) {
      final month = i.createdAt.length >= 7 ? i.createdAt.substring(0, 7) : i.createdAt;
      monthCounts[month] = (monthCounts[month] ?? 0) + 1;
    }
    final monthRows = monthCounts.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Text(
                  '통계를 표시할 데이터가 없습니다.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    '통계',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전체 기도 제목 ${items.length}건',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _StatSection(title: '유형별', rows: categoryRows),
                  const SizedBox(height: 16),
                  _StatSection(title: '대상자별', rows: personRows),
                  const SizedBox(height: 16),
                  _StatSection(title: '상태별', rows: statusRows),
                  const SizedBox(height: 16),
                  _StatSection(title: '날짜별 (월별 등록 건수)', rows: monthRows),
                ],
              ),
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> rows;

  const _StatSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final maxValue = rows.isEmpty ? 0 : rows.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text('데이터 없음', style: TextStyle(color: Colors.grey[500], fontSize: 13))
            else
              for (final row in rows) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          row.key,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: maxValue == 0 ? 0 : row.value / maxValue,
                            minHeight: 10,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                            color: colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${row.value}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
