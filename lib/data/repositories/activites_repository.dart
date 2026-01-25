import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/activites_model.dart';

class ActivitesRepository {
  Future<List<Activite>> getAllActivites() async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'activites',
      orderBy: 'DateOp DESC',
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  }

  Future <List<Activite>> getActivitesByDossierId(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM activites WHERE DossierID = ?',
      [dossierId],
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  } 

  Future<int> updateActivite(Activite activite) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'activites',
      {
        'DossierID': activite.dossierId,
        'DateOp': activite.dateOp.toIso8601String(),
        'Libelle': activite.libelle,
        'Minutes': activite.minutes,
        'Frais': activite.frais,
        'Tarif': activite.tarif,
      },
      where: 'ID_Activite = ?',
      whereArgs: [activite.idActivite],
    );
  }
    Future<int> deleteActivite(int idActivite) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'activites',
      where: 'ID_Activite = ?',
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
      'SELECT MIN(DateOp) as MinDate FROM activites WHERE DossierID = ?',
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

    String whereClause = 'DossierID = ?';
    List<dynamic> whereArgs = [dossierId];

    if (dateDu != null) {
      whereClause += ' AND DateOp >= ?';
      whereArgs.add(dateDu.toIso8601String());
    }

    if (dateAu != null) {
      whereClause += ' AND DateOp <= ?';
      whereArgs.add(dateAu.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'activites',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'DateOp DESC',
    );

    return maps.map((e) => Activite.fromMap(e)).toList();
  }

}

