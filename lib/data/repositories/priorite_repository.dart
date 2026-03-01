import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/priorite_model.dart';

class PrioriteRepository {
  Future<List<Priorite>> getAllPriorites() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'priorite',
        orderBy: 'id_priorite',
      );

      return result.map((e) => Priorite.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in PrioriteRepository.getAllPriorites: $e\n$st');
      rethrow;
    }
  }
Future<int> updatePriorite (Priorite priorite) async {
  try {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'priorite',
      {
        'priorite': priorite.label,
      },
      where: 'id_priorite = ?',
      whereArgs: [priorite.id],
    );
  } catch (e) {
    //print('Exception in updatePriorite: $e\n$st');
    rethrow;
  }
  }
}
Future<int> deletePriorite(int idPriorite) async {
  try {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'priorite',
      where: 'id_priorite = ?',
      whereArgs: [idPriorite],
    );
  } catch (e) {
    //print('Exception in deletePriorite: $e\n$st');
    rethrow;
  }
}
Future<int> insertPriorite(Priorite priorite) async {
  try {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'priorite',
      priorite.toMap(),
    );
  } catch (e) {
    //print('Exception in insertPriorite: $e\n$st');
    rethrow;
  }
}