import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/dossier_model.dart';

class DossierRepository {
  Future<List<Dossier>> getAllDossiers() async {
    final Database db = await DatabaseHelper.instance.database;

    //final List<Map<String, dynamic>> maps =
        //await db.query('dossiers', orderBy: 'Date_creation DESC');
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        d.ID_Dossier,
        d.Libelle,
        d.Tarif,
        d.Priorite,
        p.lblPriorite,
        d.Archive,
        d.TVA,
        d.Afaire,
        d.Date_creation,
        d.Date_archive,
        d.No_archive,
        d.Ref_tribunal
      FROM dossiers d
      LEFT JOIN priorite p
        ON p.ID_Priorite = d.Priorite
      ORDER BY d.Priorite ASC
    ''');
    return result.map((e) => Dossier.fromMap(e)).toList();
  }

Future<int> updateDossier(Dossier dossier) async {
  final db = await DatabaseHelper.instance.database;

    return await db.update(
    'dossiers',
    {
      'Libelle': dossier.libelle,
      'Tarif': dossier.tarif,
      'TVA': dossier.tva,
      'Priorite': dossier.prioriteId,
      'Afaire': dossier.afaire,
      'Ref_tribunal': dossier.refTribunal,
      'Archive': dossier.archive ? 1 : 0,
      'Date_archive': dossier.dateArchive?.toIso8601String(),
      'No_archive': dossier.noArchive,
      'Date_creation': dossier.dateCreation?.toIso8601String(),
    },
    where: 'ID_Dossier = ?',
    whereArgs: [dossier.id],
  );
  }
}
Future<int> deleteDossier(int idDossier) async {
  final db = await DatabaseHelper.instance.database;

  return await db.delete(
    'dossiers',
    where: 'ID_Dossier = ?',
    whereArgs: [idDossier],
  );
}

Future<int> insertDossier(Dossier dossier) async {
  final db = await DatabaseHelper.instance.database;

  return await db.insert(
    'dossiers',
    {
      'Libelle': dossier.libelle,
      'Tarif': dossier.tarif,
      'TVA': dossier.tva,
      'Priorite': dossier.prioriteId,
      'Afaire': dossier.afaire,
      'Ref_tribunal': dossier.refTribunal,
      'Archive': dossier.archive ? 1 : 0,
      'Date_archive': dossier.dateArchive?.toIso8601String(),
      'No_archive': dossier.noArchive,
      'Date_creation': dossier.dateCreation?.toIso8601String(),
    },
  );
}