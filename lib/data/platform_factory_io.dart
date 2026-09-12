import 'dart:io';

// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart'; // sets the default (mobile) databaseFactory as a side effect
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DatabaseFactory resolveDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }
  return databaseFactory;
}
