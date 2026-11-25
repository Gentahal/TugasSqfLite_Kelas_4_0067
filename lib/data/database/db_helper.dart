import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DbHelper {
  static const _dbName = 'Barang.db';
  static const _version = 1;

  static const tableName = "barang";

  static const createTable =
      """
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    stok INTEGER NOT NULL
  )
  """;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        _dbName,
        version: _version,
        onCreate: (db, version) async {
          await db.execute(createTable);
        },
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getDatabasesPath();
    final path = '$dir/$_dbName';

    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute(createTable);
      },
    );
  }
}
