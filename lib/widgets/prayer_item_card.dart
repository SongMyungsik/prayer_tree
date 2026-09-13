import 'package:flutter/material.dart';

import '../data/prayer_store.dart';
import '../models/prayer_item.dart';
import '../screens/item_detail_screen.dart';
import 'category_pill.dart';
import 'status_badge.dart';

class PrayerItemCard extends StatelessWidget {
  final PrayerItem item;
  final PrayerStore store;

  const PrayerItemCard({super.key, required this.item, required this.store});

  @override
  Widget build(BuildContext context) {
    final category = store.categoryById(item.categoryId);
    final categoryColor = category != null ? Color(category.color) : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id!, store: store)),
        );
      },
      child: Card(
        color: categoryColor?.withValues(alpha: isDark ? 0.20 : 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: categoryColor?.withValues(alpha: 0.35) ?? const Color(0xFFE6E2EE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: categoryColor ?? Colors.transparent),
              Expanded(
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
                                if (item.personName != null || category != null) ...[
                                  Row(
                                    children: [
                                      if (item.personName != null)
                                        Text(
                                          item.personName!,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      if (item.personName != null && category != null)
                                        const SizedBox(width: 6),
                                      if (category != null)
                                        CategoryPill(name: category.name, color: categoryColor!),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (item.description != null && item.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          StatusBadge(status: item.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
