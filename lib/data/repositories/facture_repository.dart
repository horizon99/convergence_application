import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/facture_model.dart';

class FactureRepository {
  Future<List<Facture>> getAllFactures() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query('facture');

    return result.map((e) => Facture.fromMap(e)).toList();
  }

  Future<int> updateFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'facture',
      facture.toMap(),
      where: 'ID_Facture = ?',
      whereArgs: [facture.idFacture],
    );
  }

  Future<int> insertFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert('facture', facture.toMap());
  }

  Future<int> deleteFacture(int idFacture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'facture',
      where: 'ID_Facture = ?',
      whereArgs: [idFacture],
    );
  }
}