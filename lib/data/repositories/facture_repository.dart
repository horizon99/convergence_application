import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/facture_model.dart';

class FactureRepository {
  Future<List<Facture>> getAllFactures() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query('factures');

    return result.map((e) => Facture.fromMap(e)).toList();
  }

  Future<List<Facture>> getFacturesFromDossier(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'factures',
      where: 'dossier_id = ?', 
      whereArgs: [dossierId],
    );

    return result.map((e) => Facture.fromMap(e)).toList();
  }

  Future<Facture?> getFactureById(int idFacture) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'factures',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Facture.fromMap(result.first);
  }

  Future<int> updateFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'factures',
      facture.toMap(),
      where: 'id_facture = ?',
      whereArgs: [facture.idFacture],
    );
  }

  Future<int> insertFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert('factures', facture.toMap());
  }

  Future<int> deleteFacture(int idFacture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'factures',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
    );
  }
}