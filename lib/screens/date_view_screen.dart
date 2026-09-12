import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/prayer_store.dart';
import '../models/progress_update.dart';
import '../widgets/prayer_item_card.dart';

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

    final selectedKey = _key(_selectedDay);
    final updatesToday = byDate[selectedKey] ?? const <ProgressUpdate>[];
    final updatesByItemId = <int, List<ProgressUpdate>>{};
    for (final u in updatesToday) {
      updatesByItemId.putIfAbsent(u.itemId, () => []).add(u);
    }
    final relatedItemIds = <int>{
      for (final item in store.items)
        if (item.createdAt.startsWith(selectedKey)) item.id!,
      ...updatesToday.map((u) => u.itemId),
    };
    final relatedItems = store.items.where((i) => relatedItemIds.contains(i.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2100, 12, 31),
              focusedDay: _focusedDay,
              rowHeight: 34,
              daysOfWeekHeight: 16,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: (day) => byDate[_key(day)] ?? const [],
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.all(2),
                defaultTextStyle: TextStyle(fontSize: 12),
                weekendTextStyle: TextStyle(fontSize: 12),
                outsideTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                headerPadding: EdgeInsets.symmetric(vertical: 4),
                titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 11),
                weekendStyle: TextStyle(fontSize: 11),
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, day, focusedDay) => _DayCell(
                  day: day,
                  isToday: isSameDay(day, DateTime.now()),
                  selected: true,
                ),
                todayBuilder: (context, day, focusedDay) =>
                    _DayCell(day: day, isToday: true, selected: false),
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 1,
                    child: Text(
                      '${events.length}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: relatedItems.isEmpty
                  ? Center(
                      child: Text(
                        '$selectedKey에 해당하는 기도 제목이 없습니다.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: relatedItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = relatedItems[index];
                        final records = updatesByItemId[item.id] ?? const <ProgressUpdate>[];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PrayerItemCard(item: item, store: store),
                            if (records.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: records
                                      .map(
                                        (u) => Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            '• ${u.content}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
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

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool selected;

  const _DayCell({required this.day, required this.isToday, required this.selected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final filled = selected && !isToday;
    return Center(
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? primary : Colors.transparent,
          border: isToday ? Border.all(color: Colors.red, width: 1.4) : null,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : (isToday ? Colors.red : null),
          ),
        ),
      ),
    );
  }
}
