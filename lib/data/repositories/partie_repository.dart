import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/partie_model.dart';

class PartieRepository {
  Future<List<Partie>> getPartieByDossier(int dossierId) async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'parties',
        where: 'dossier_id = ?',
        whereArgs: [dossierId],
        orderBy: 'role ASC',
      );

      return result.map((e) => Partie.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in PartieRepository.getPartieByDossier: $e\n$st');
      rethrow;
    }
  }

  Future<Partie> getPartieById(int idPartie) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'parties',
        where: 'id_partie = ?',
        whereArgs: [idPartie],
      );
      return Partie.fromMap(result.first);
    } catch (e) {
      //print('Exception in PartieRepository.getPartieById: $e\n$st');
      rethrow;
    }
  }

  Future<int> updatePartie(Partie partie) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.update(
        'parties',
        partie.toMap(),
        where: 'id_partie = ?',
        whereArgs: [partie.idPartie],
      );
    } catch (e) {
      //print('Exception in PartieRepository.updatePartie: $e\n$st');
      rethrow;
    }
  }

  Future<int> deletePartie(int idPartie) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.delete(
        'parties',
        where: 'id_partie = ?',
        whereArgs: [idPartie],
      );
    } catch (e) {
      //print('Exception in PartieRepository.deletePartie: $e\n$st');
      rethrow;
    }
  }

  Future<int> insertPartie(Partie partie) async {
    final db = await DatabaseHelper.instance.database;

    try {
      final result = await db.insert('parties', partie.toMap());
      //print('Insert successful, new ID: $result');
      return result;
    } catch (e) {
      //print('Error inserting partie: $e');
      rethrow;
    }
  }
}
