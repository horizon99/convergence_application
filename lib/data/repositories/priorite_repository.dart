import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/priorite_model.dart';

class PrioriteRepository {
  Future<List<Priorite>> getAllPriorites() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'priorite',
      orderBy: 'id_priorite',
    );

    return result.map((e) => Priorite.fromMap(e)).toList();
  }
Future<int> updatePriorite (Priorite priorite) async {
  final db = await DatabaseHelper.instance.database;

    return await db.update(
    'priorite',
    {
      'priorite': priorite.label,
    },
    where: 'id_priorite = ?',
    whereArgs: [priorite.id],
  );
  }
}
Future<int> deletePriorite(int idPriorite) async {
  final db = await DatabaseHelper.instance.database;

  return await db.delete(
    'priorite',
    where: 'id_priorite = ?',
    whereArgs: [idPriorite],
  );
}
Future<int> insertPriorite(Priorite priorite) async {
  final db = await DatabaseHelper.instance.database;

  return await db.insert(
    'priorite',
    priorite.toMap(),
  );
}