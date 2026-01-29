import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/dossier_model.dart';

class DossierRepository {
  Future<Dossier?> getDossierById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        d.id_dossier,
        d.libelle,
        d.groupe_tarif,
        d.priorite_id,
        p.priorite_text,
        d.archive,
        d.tva,
        d.a_faire,
        d.date_creation,
        d.date_archive,
        d.no_archive,
        d.ref_tribunal,
        d.libelle_client,
        d.notes
      FROM dossiers d
      LEFT JOIN priorite p
        ON p.id_priorite = d.priorite_id
      WHERE d.id_dossier = ?
    ''', [id]);

    if (result.isNotEmpty) {
      return Dossier.fromMap(result.first);
    }
    return null;
  }


  Future<List<Dossier>> getAllDossiers() async {
    final Database db = await DatabaseHelper.instance.database;

    //final List<Map<String, dynamic>> maps =
    //await db.query('dossiers', orderBy: 'Date_creation DESC');
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        d.id_dossier,
        d.libelle,
        d.groupe_tarif,
        d.priorite_id,
        p.priorite_text,
        d.archive,
        d.tva,
        d.a_faire,
        d.date_creation,
        d.date_archive,
        d.no_archive,
        d.ref_tribunal,
        d.libelle_client,
        d.notes
      FROM dossiers d
      LEFT JOIN priorite p
        ON p.id_priorite = d.priorite_id
      ORDER BY d.priorite_id ASC
    ''');
    return result.map((e) => Dossier.fromMap(e)).toList();
  }

  Future<int> updateDossier(Dossier dossier) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'dossiers',
      {
        'libelle': dossier.libelle,
        'groupe_tarif': dossier.groupeTarif,
        'tva': dossier.tva,
        'priorite_id': dossier.prioriteId,
        'a_faire': dossier.afaire,
        'ref_tribunal': dossier.refTribunal,
        'archive': dossier.archive ? 1 : 0,
        'date_archive': dossier.dateArchive?.toIso8601String(),
        'no_archive': dossier.noArchive,
        'date_creation': dossier.dateCreation?.toIso8601String(),
        'libelle_client': dossier.libelleClient,
        'notes': dossier.notes,
      },
      where: 'id_dossier = ?',
      whereArgs: [dossier.id],
    );
  }
}

Future<int> deleteDossier(int idDossier) async {
  final db = await DatabaseHelper.instance.database;

  return await db.delete(
    'dossiers',
    where: 'id_dossier = ?',
    whereArgs: [idDossier],
  );
}

Future<int> insertDossier(Dossier dossier) async {
  final db = await DatabaseHelper.instance.database;

  return await db.insert('dossiers', {
    'libelle': dossier.libelle,
    'groupe_tarif': dossier.groupeTarif,
    'tva': dossier.tva,
    'priorite_id': dossier.prioriteId,
    'a_faire': dossier.afaire,
    'ref_tribunal': dossier.refTribunal,
    'archive': dossier.archive ? 1 : 0,
    'date_archive': dossier.dateArchive?.toIso8601String(),
    'no_archive': dossier.noArchive,
    'date_creation': dossier.dateCreation?.toIso8601String(),
    'libelle_client': dossier.libelleClient,
    'notes': dossier.notes,
  });
}
