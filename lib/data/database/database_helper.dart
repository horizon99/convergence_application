import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/mediateur_model.dart';

class DatabaseNotSelectedException implements Exception {
  @override
  String toString() {
    return 'Aucune base de donnees SQLite n\'est selectionnee.';
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static String? _selectedDatabasePath;

  DatabaseHelper._internal();

  String? get selectedDatabasePath => _selectedDatabasePath;

  bool get hasSelectedDatabase => _selectedDatabasePath != null;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (_selectedDatabasePath == null) {
      throw DatabaseNotSelectedException();
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = _selectedDatabasePath;
    if (dbPath == null) {
      throw DatabaseNotSelectedException();
    }

    final db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        onConfigure: (db) async {
          // On macOS sandbox, a user-selected file can be writable while
          // sidecar files are denied; keep journals/temp in memory.
          if (Platform.isMacOS) {
            await db.execute('PRAGMA journal_mode=MEMORY');
            await db.execute('PRAGMA temp_store=MEMORY');
          }
        },
      ),
    );
    await _runSchemaSync(db);
    return db;
  }

  Future<void> _runSchemaSync(Database db) async {
    // Migration defensive: derive les colonnes depuis le modele.
    await _ensureModelColumnsExist(
      db: db,
      table: 'mediateur',
      modelMap: Mediateur(idMediateur: 0).toMap(),
      excludedColumns: {'id_mediateur'},
      typeOverrides: {
        'logo': 'BLOB',
        'logo_x': 'INTEGER',
        'logo_y': 'INTEGER',
        'logo_w': 'INTEGER',
        'logo_h': 'INTEGER',
        'en_tete_papier_x': 'INTEGER',
        'en_tete_papier_y': 'INTEGER',
      },
    );
  }

  Future<void> _ensureModelColumnsExist({
    required Database db,
    required String table,
    required Map<String, dynamic> modelMap,
    Set<String> excludedColumns = const {},
    Map<String, String> typeOverrides = const {},
  }) async {
    for (final entry in modelMap.entries) {
      if (excludedColumns.contains(entry.key)) {
        continue;
      }

      await _ensureColumnExists(
        db,
        table,
        entry.key,
        _resolveSqlType(entry.key, entry.value, typeOverrides),
      );
    }
  }

  String _resolveSqlType(
    String column,
    dynamic value,
    Map<String, String> typeOverrides,
  ) {
    final override = typeOverrides[column];
    if (override != null) {
      return override;
    }

    if (value is int || value is bool) {
      return 'INTEGER';
    }
    if (value is double || value is num) {
      return 'REAL';
    }
    if (value is Uint8List) {
      return 'BLOB';
    }
    return 'TEXT';
  }

  Future<void> _ensureColumnExists(
    Database db,
    String table,
    String column,
    String sqlType,
  ) async {
    if (!await _tableExists(db, table)) {
      return;
    }

    final tableInfo = await db.rawQuery('PRAGMA table_info($table)');
    final hasColumn = tableInfo.any((row) => row['name'] == column);
    if (!hasColumn) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $sqlType');
    }
  }

  Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      ['table', table],
    );
    return result.isNotEmpty;
  }

  Future<void> openDatabaseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('Fichier SQLite introuvable: $filePath');
    }

    await closeDatabase();
    _selectedDatabasePath = filePath;
    _database = await _initDatabase();

    // Validation minimale pour confirmer que le fichier est une base SQLite lisible.
    await _database!.rawQuery('SELECT name FROM sqlite_master LIMIT 1');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
