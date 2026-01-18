import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 1️⃣ Initialiser sqflite FFI pour Desktop
    // sqfliteFfiInit();

    // 2️⃣ Utiliser databaseFactoryFfi
    final dbFactory = databaseFactoryFfi;   

    // 3️⃣ Définir le chemin du fichier SQLite
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'convergence_db.sqlite');

    // 4️⃣ Copier la DB depuis assets si elle n'existe pas encore
    final exists = await dbFactory.databaseExists(path);

    if (!exists) {
      await Directory(dirname(path)).create(recursive: true);
      final data = await rootBundle.load('assets/db/convergence_db.sqlite');
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // 5️⃣ Ouvrir la base avec FFI
    return await dbFactory.openDatabase(path);
  }
}
