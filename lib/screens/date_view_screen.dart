import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/prayer_store.dart';
import '../models/progress_update.dart';
import '../widgets/category_pill.dart';
import 'item_detail_screen.dart';

class DateViewScreen extends StatefulWidget {
  final PrayerStore store;

  const DateViewScreen({super.key, required this.store});

  @override
  State<DateViewScreen> createState() => _DateViewScreenState();
}

class _DateViewScreenState extends State<DateViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final Map<String, List<ProgressUpdate>> byDate = {};
    for (final u in store.updates) {
      byDate.putIfAbsent(u.date, () => []).add(u);
    }

    final selectedEntries = byDate[_key(_selectedDay)] ?? const <ProgressUpdate>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: (day) => byDate[_key(day)] ?? const [],
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            const Divider(height: 1),
            Expanded(
              child: selectedEntries.isEmpty
                  ? Center(
                      child: Text(
                        '${_key(_selectedDay)}에 기록된 진행 상황이 없습니다.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedEntries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final u = selectedEntries[index];
                        final item = store.itemById(u.itemId);
                        final category = item != null ? store.categoryById(item.categoryId) : null;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: item == null
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailScreen(itemId: item.id!, store: store),
                                    ),
                                  ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item?.title ?? '(삭제된 항목)',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (category != null)
                                        CategoryPill(name: category.name, color: Color(category.color)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(u.content, style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
