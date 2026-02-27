import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/ecriture_model.dart';

class EcrituresRepository {
  Future<List<Ecriture>> getAll({int? factureId}) async {
    final Database db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'ecritures',
      where: factureId != null ? 'facture_id = ?' : null,
      whereArgs: factureId != null ? [factureId] : null,
      orderBy: 'date DESC, id_ecriture DESC',
    );

    return result.map((e) => Ecriture.fromMap(e)).toList();
  }

  Future<Ecriture?> getById(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'ecritures',
      where: 'id_ecriture = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) return Ecriture.fromMap(result.first);
    return null;
  }

  Future<int> insert(Ecriture e) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('ecritures', e.toMap());
  }

  Future<int> update(Ecriture e) async {
    final db = await DatabaseHelper.instance.database;
    final map = Map<String, dynamic>.from(e.toMap());
    map.remove('id');
    return await db.update(
      'ecritures',
      map,
      where: 'id_ecriture = ?',
      whereArgs: [e.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('ecritures', where: 'id_ecriture = ?', whereArgs: [id]);
  }

  Future<double> sumMontant({int? factureId}) async {
    final db = await DatabaseHelper.instance.database;
    final where = factureId != null ? 'WHERE facture_id = ?' : '';
    final sql = 'SELECT SUM(montant) as total FROM ecritures $where';
    final result = await db.rawQuery(sql, factureId != null ? [factureId] : null);
    if (result.isNotEmpty) {
      final v = result.first['total'];
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }
    return 0.0;
  }
}
