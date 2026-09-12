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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id!, store: store)),
        );
      },
      child: Card(
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
                        if (item.personName != null) ...[
                          Text(
                            item.personName!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              if (category != null) ...[
                const SizedBox(height: 8),
                CategoryPill(name: category.name, color: Color(category.color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
