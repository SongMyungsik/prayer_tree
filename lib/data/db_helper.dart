import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart'; // sets the default (mobile) databaseFactory as a side effect
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const List<Map<String, Object>> defaultCategories = [
  {'name': '환우', 'color': 0xFFE0708A},
  {'name': '수험생', 'color': 0xFF5B8FD6},
  {'name': '취업', 'color': 0xFF5AAB8F},
  {'name': '결혼', 'color': 0xFFC98FD6},
  {'name': '가정', 'color': 0xFFD69A5B},
  {'name': '기타', 'color': 0xFF8A8794},
];

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final DatabaseFactory factory;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    } else {
      factory = databaseFactory;
    }

    final dbPath = await factory.getDatabasesPath();
    final path = join(dbPath, 'prayer_tree.db');

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              color INTEGER NOT NULL,
              sort_order INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              person_name TEXT,
              description TEXT,
              status TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE updates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              item_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              content TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          final batch = db.batch();
          for (var i = 0; i < defaultCategories.length; i++) {
            batch.insert('categories', {
              'name': defaultCategories[i]['name'],
              'color': defaultCategories[i]['color'],
              'sort_order': i,
            });
          }
          await batch.commit(noResult: true);
        },
      ),
    );
  }
}
