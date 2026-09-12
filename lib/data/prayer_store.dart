import 'package:flutter/foundation.dart';

import '../models/prayer_category.dart';
import '../models/prayer_item.dart';
import '../models/prayer_status.dart';
import '../models/progress_update.dart';
import 'db_helper.dart';

class PrayerStore extends ChangeNotifier {
  List<PrayerCategory> categories = [];
  List<PrayerItem> items = [];
  List<ProgressUpdate> updates = [];
  bool loaded = false;

  Future<void> load() async {
    final db = await DbHelper.instance.database;
    final categoryRows = await db.query('categories', orderBy: 'sort_order');
    final itemRows = await db.query('items', orderBy: 'created_at DESC');
    final updateRows = await db.query('updates', orderBy: 'date DESC');

    categories = categoryRows.map(PrayerCategory.fromMap).toList();
    items = itemRows.map(PrayerItem.fromMap).toList();
    updates = updateRows.map(ProgressUpdate.fromMap).toList();
    loaded = true;
    notifyListeners();
  }

  PrayerCategory? categoryById(int id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  PrayerItem? itemById(int id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<ProgressUpdate> updatesForItem(int itemId) {
    return updates.where((u) => u.itemId == itemId).toList();
  }

  int itemCountForCategory(int categoryId) {
    return items.where((i) => i.categoryId == categoryId).length;
  }

  String _nowIso() => DateTime.now().toIso8601String();

  Future<void> addCategory(String name, int color) async {
    final db = await DbHelper.instance.database;
    final nextOrder = categories.isEmpty
        ? 0
        : categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await db.insert('categories', {'name': name, 'color': color, 'sort_order': nextOrder});
    await load();
  }

  Future<void> updateCategory(int id, String name, int color) async {
    final db = await DbHelper.instance.database;
    await db.update('categories', {'name': name, 'color': color}, where: 'id = ?', whereArgs: [id]);
    await load();
  }

  Future<void> deleteCategory(int id) async {
    final db = await DbHelper.instance.database;
    final itemIds = items.where((i) => i.categoryId == id).map((i) => i.id).toList();
    final batch = db.batch();
    for (final itemId in itemIds) {
      batch.delete('updates', where: 'item_id = ?', whereArgs: [itemId]);
    }
    batch.delete('items', where: 'category_id = ?', whereArgs: [id]);
    batch.delete('categories', where: 'id = ?', whereArgs: [id]);
    await batch.commit(noResult: true);
    await load();
  }

  Future<int> addItem({
    required int categoryId,
    required String title,
    String? personName,
    String? description,
  }) async {
    final db = await DbHelper.instance.database;
    final now = _nowIso();
    final id = await db.insert('items', {
      'category_id': categoryId,
      'title': title,
      'person_name': personName,
      'description': description,
      'status': PrayerStatus.praying.name,
      'created_at': now,
      'updated_at': now,
    });
    await load();
    return id;
  }

  Future<void> updateItem(
    int id, {
    required int categoryId,
    required String title,
    String? personName,
    String? description,
  }) async {
    final db = await DbHelper.instance.database;
    await db.update(
      'items',
      {
        'category_id': categoryId,
        'title': title,
        'person_name': personName,
        'description': description,
        'updated_at': _nowIso(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await load();
  }

  Future<void> setItemStatus(int id, PrayerStatus status) async {
    final db = await DbHelper.instance.database;
    await db.update(
      'items',
      {'status': status.name, 'updated_at': _nowIso()},
      where: 'id = ?',
      whereArgs: [id],
    );
    await load();
  }

  Future<void> deleteItem(int id) async {
    final db = await DbHelper.instance.database;
    final batch = db.batch();
    batch.delete('updates', where: 'item_id = ?', whereArgs: [id]);
    batch.delete('items', where: 'id = ?', whereArgs: [id]);
    await batch.commit(noResult: true);
    await load();
  }

  Future<void> addProgressUpdate(int itemId, String date, String content) async {
    final db = await DbHelper.instance.database;
    await db.insert('updates', {
      'item_id': itemId,
      'date': date,
      'content': content,
      'created_at': _nowIso(),
    });
    await db.update('items', {'updated_at': _nowIso()}, where: 'id = ?', whereArgs: [itemId]);
    await load();
  }

  Future<void> deleteProgressUpdate(int id) async {
    final db = await DbHelper.instance.database;
    await db.delete('updates', where: 'id = ?', whereArgs: [id]);
    await load();
  }
}
