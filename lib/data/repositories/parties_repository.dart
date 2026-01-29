import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/parties_model.dart';

class PartiesRepository {
  Future<List<Parties>> getPartiesByDossier(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        p.id_partie,
        p.contact_id,
        p.dossier_id,
        p.attention,
        p.role,
        p.concerne,
        p.participation,
        c.nom || ' ' || IFNULL(c.prenom, '') AS nom_prenom,
        c.tel_fixe,
        c.tel_mobile,
        c.email
      FROM parties p
      JOIN contacts c ON c.id_contact = p.contact_id
      WHERE p.dossier_id = ?
      ORDER BY c.nom, c.prenom
      ''',
      [dossierId],
    );

    return maps.map((e) => Parties.fromMap(e)).toList();
  }
  
  Future<int> deletePartie(int idPartie) async {
  final db = await DatabaseHelper.instance.database;

  return await db.delete(
    'parties',
    where: 'id_partie = ?',
    whereArgs: [idPartie],
  );
}
}