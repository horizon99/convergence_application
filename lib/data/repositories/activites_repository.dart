import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/activites_model.dart';

class ActivitesRepository {
  Future<List<Activite>> getAllActivites() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'activites',
        orderBy: 'date_activite DESC',
      );

      return maps.map((e) => Activite.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ActivitesRepository.getAllActivites: $e\n$st');
      rethrow;
    }
  }

  Future <List<Activite>> getActivitesByDossierId(int dossierId) async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM activites WHERE dossier_id = ?',
        [dossierId],
      );

      return maps.map((e) => Activite.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ActivitesRepository.getActivitesByDossierId: $e\n$st');
      rethrow;
    }
  } 

  Future<int> updateActivite(Activite activite) async {
    try {
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
    } catch (e) {
      //print('Exception in ActivitesRepository.updateActivite: $e\n$st');
      rethrow;
    }
  }
    Future<int> deleteActivite(int idActivite) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.delete(
        'activites',
        where: 'id_activite = ?',
        whereArgs: [idActivite],
      );
    } catch (e) {
      //print('Exception in ActivitesRepository.deleteActivite: $e\n$st');
      rethrow;
    }
  }

  Future<int> insertActivite(Activite activite) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.insert(
        'activites',
        activite.toMap(),
      );
    } catch (e) {
      //print('Exception in ActivitesRepository.insertActivite: $e\n$st');
      rethrow;
    }
  }

  Future<DateTime?> getMinDateByDossier(int dossierId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT MIN(date_activite) as MinDate FROM activites WHERE dossier_id = ?',
        [dossierId],
      );

      if (result.isNotEmpty && result.first['MinDate'] != null) {
        return DateTime.parse(result.first['MinDate']);
      }
      return null;
    } catch (e) {
      //print('Exception in ActivitesRepository.getMinDateByDossier: $e\n$st');
      rethrow;
    }
  }

  Future<List<Activite>> getActivitesByDossierDuAu(
    int dossierId, {
    DateTime? dateDu,
    DateTime? dateAu,
  }) async {
    try {
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
    } catch (e) {
      //print('Exception in ActivitesRepository.getActivitesByDossierDuAu: $e\n$st');
      rethrow;
    }
  }

}
