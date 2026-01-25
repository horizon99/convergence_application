import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/tarifs_model.dart';

class TarifsRepository {
  Future<List<ModeleTarif>> getAllTarifs() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query('tarifs', orderBy: 'Groupe ASC, Ordre ASC');

    return result.map((e) => ModeleTarif.fromMap(e)).toList();
  }

  Future<int> updateTarif(ModeleTarif tarif) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'tarifs',
      tarif.toMap(),
      where: 'ID_ModeleTarif = ?',
      whereArgs: [tarif.idTarif]  ,
    );
  }

  Future<int> insertTarif(ModeleTarif tarif) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert('tarifs', tarif.toMap());
  }

  Future<int> deleteTarif(int idTarif) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'tarifs',
      where: 'ID_ModeleTarif = ?',
      whereArgs: [idTarif],
    );
  }
}
