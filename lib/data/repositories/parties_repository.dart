import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/parties_model.dart';

class PartiesRepository {
  Future<List<Parties>> getPartiesByDossier(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        p.ID_Partie,
        p.ContactID,
        p.DossierID,
        p.Attention,
        p.Role,
        p.Concerne,
        p.Facturable,
        c.Nom || ' ' || IFNULL(c.Prenom, '') AS NomPrenom,
        c.Tel_fixe,
        c.Tel_mobile,
        c.Email
      FROM parties p
      JOIN contacts c ON c.ID_Contact = p.ContactID
      WHERE p.DossierID = ?
      ORDER BY c.Nom, c.Prenom
      ''',
      [dossierId],
    );

    return maps.map((e) => Parties.fromMap(e)).toList();
  }
  
  Future<int> deletePartie(int idPartie) async {
  final db = await DatabaseHelper.instance.database;

  return await db.delete(
    'parties',
    where: 'ID_Partie = ?',
    whereArgs: [idPartie],
  );
}
}