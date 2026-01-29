import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/partie_model.dart';

class PartieRepository {
  Future<List<Partie>> getPartieByDossier(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'parties',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'role ASC',
    );

    return result.map((e) => Partie.fromMap(e)).toList();
  }

  Future<Partie> getPartieById(int idPartie) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'parties',
      where: 'id_partie = ?',
      whereArgs: [idPartie],
    );
    return Partie.fromMap(result.first);
  }

  Future<int> updatePartie(Partie partie) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'parties',
      partie.toMap(),
      where: 'id_partie = ?',
      whereArgs: [partie.idPartie],
    );
  }

  Future<int> deletePartie(int idPartie) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'parties',
      where: 'id_partie = ?',
      whereArgs: [idPartie],
    );
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
