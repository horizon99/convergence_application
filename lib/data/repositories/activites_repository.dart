import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/activites_model.dart';

class ActivitesRepository {
  Future<List<Activite>> getAllActivites() async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'activites',
      orderBy: 'date_activite DESC',
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  }

  Future <List<Activite>> getActivitesByDossierId(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM activites WHERE dossier_id = ?',
      [dossierId],
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  } 

  Future<int> updateActivite(Activite activite) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'activites',
      {
        'dossier_id': activite.dossierId,
        'date_activite': activite.dateActivite.toIso8601String(),
        'libelle': activite.libelle,
        'minutes': activite.minutes,
        'frais': activite.frais,
        'code_tarif': activite.codeTarif,
      },
      where: 'id_activite = ?',
      whereArgs: [activite.idActivite],
    );
  }
    Future<int> deleteActivite(int idActivite) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'activites',
      where: 'id_activite = ?',
      whereArgs: [idActivite],
    );
  }

  Future<int> insertActivite(Activite activite) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'activites',
      activite.toMap(),
    );
  }

  Future<DateTime?> getMinDateByDossier(int dossierId) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MIN(date_activite) as MinDate FROM activites WHERE dossier_id = ?',
      [dossierId],
    );

    if (result.isNotEmpty && result.first['MinDate'] != null) {
      return DateTime.parse(result.first['MinDate']);
    }
    return null;
  }

  Future<List<Activite>> getActivitesByDossierDuAu(
    int dossierId, {
    DateTime? dateDu,
    DateTime? dateAu,
  }) async {
    final db = await DatabaseHelper.instance.database;

    String whereClause = 'dossier_id = ?';
    List<dynamic> whereArgs = [dossierId];

    if (dateDu != null) {
      whereClause += ' AND date_activite >= ?';
      whereArgs.add(dateDu.toIso8601String());
    }

    if (dateAu != null) {
      whereClause += ' AND date_activite <= ?';
      whereArgs.add(dateAu.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'activites',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date_activite DESC',
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  }

}
