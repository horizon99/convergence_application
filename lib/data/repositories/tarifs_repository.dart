import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/tarifs_model.dart';

class TarifsRepository {
  Future<List<ModeleTarif>> getAllModelesTarifs() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'tarifs',
      orderBy: 'ID_ModeleTarif',
    );

    return result.map((e) => ModeleTarif.fromMap(e)).toList();
  }
  Future<int> updateDossier (ModeleTarif modeleTarif) async {
  final db = await DatabaseHelper.instance.database;

    return await db.update(
    'tarifs',
    {
      'Modèle': modeleTarif.modele,
    },
    where: 'ID_ModeleTarif = ?',
    whereArgs: [modeleTarif.id],
  );
  }
}
