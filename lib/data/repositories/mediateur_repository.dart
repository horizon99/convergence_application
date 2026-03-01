import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/mediateur_model.dart';
import '../database/database_helper.dart';

class MediateurRepository { 
  Future<List<Mediateur>> getAllMediateurs() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'mediateurs',
        orderBy: 'id_mediateur ASC',
      );

      return result.map((e) => Mediateur.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in MediateurRepository.getAllMediateurs: $e\n$st');
      rethrow;
    }
  } 

  Future<Mediateur> getMediateur() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.rawQuery(
        'SELECT * FROM mediateur LIMIT 1',
      );
      final resultFirst = result.first;

      return Mediateur.fromMap(resultFirst);
    } catch (e) {
      //print('Exception in MediateurRepository.getMediateur: $e\n$st');
      rethrow;
    }
  } 

  Future<int> updateMediateur(Mediateur mediateur) async {
    try {
      final Database db = await DatabaseHelper.instance.database;
      return await db.update(
        'mediateur',
        mediateur.toMap(),
        where: 'id_mediateur = ?',
        whereArgs: [mediateur.idMediateur],
      );
    } catch (e) {
      //print('Exception in MediateurRepository.updateMediateur: $e\n$st');
      rethrow;
    }
  }
}