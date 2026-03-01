import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/tarifs_model.dart';

class TarifsRepository {
  Future<List<ModeleTarif>> getAllTarifs() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query('tarifs', orderBy: 'groupe ASC, ordre ASC');

      return result.map((e) => ModeleTarif.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in TarifsRepository.getAllTarifs: $e\n$st');
      rethrow;
    }
  }

  Future<int> updateTarif(ModeleTarif tarif) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.update(
        'tarifs',
        tarif.toMap(),
        where: 'id_tarif = ?',
        whereArgs: [tarif.idTarif]  ,
      );
    } catch (e) {
      //print('Exception in TarifsRepository.updateTarif: $e\n$st');
      rethrow;
    }
  }

  Future<int> insertTarif(ModeleTarif tarif) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.insert('tarifs', tarif.toMap());
    } catch (e) {
      //print('Exception in TarifsRepository.insertTarif: $e\n$st');
      rethrow;
    }
  }

  Future<int> deleteTarif(int idTarif) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.delete(
        'tarifs',
        where: 'id_tarif = ?',
        whereArgs: [idTarif],
      );
    } catch (e) {
      //print('Exception in TarifsRepository.deleteTarif: $e\n$st');
      rethrow;
    }
  }
}
