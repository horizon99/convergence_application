import '../database/database_helper.dart';
import '../../models/activites_model.dart';
import '../../models/activites_facturables_model.dart';

class ActivitesFacturablesRepository {
  // Repository methods and properties go here
  Future<List<ActiviteFacturable>> getActivitesFacturables(
    int dossierId, {
    DateTime? dateDu,
    DateTime? dateAu,
  }) async {
    final db = await DatabaseHelper.instance.database;
    
    String whereClause = 'DossierID = ?';
    List<dynamic> whereArgs = [dossierId];

    if (dateDu != null) {
      whereClause += ' AND DateOp >= ?';
      whereArgs.add(dateDu.toIso8601String());
    }

    if (dateAu != null) {
      whereClause += ' AND DateOp <= ?';
      whereArgs.add(dateAu.toIso8601String());
    }

    final baseSql = '''
    SELECT
      a.ID_Activite,
      a.DateOp,
      a.Libelle,
      a.Minutes,
      a.Frais,
      a.DossierID,
      a.Tarif AS code_tarif,
      IFNULL(t.Description, a.Tarif) AS description_tarif,
      IFNULL(t.Tarif, 0) AS tarif_horaire,
      (( IFNULL(a.Minutes, 0) * IFNULL(t.Tarif, 0)/60 ) + IFNULL(a.Frais, 0)) AS montant_facturable,
      IFNULL(t.Groupe, '-') AS groupe_tarif,
      IFNULL(t.Ordre, 0) AS ordre_tarif
    FROM activites a
    LEFT OUTER JOIN tarifs t ON t.Code = a.Tarif
  ''';

    String sql = baseSql;
    if (whereClause.isNotEmpty) {
      sql += ' WHERE $whereClause';
    }
    sql += ' ORDER BY a.DateOp ASC';

    final result = await db.rawQuery(sql, whereArgs);

    return result.map((row) {
      final activite = Activite(
        idActivite: row['ID_Activite'] as int,
        dateOp: DateTime.parse(row['DateOp'] as String),
        libelle: row['Libelle'] as String,
        minutes: (row['Minutes'] as num?)?.toInt(),
        frais: (row['Frais'] as num?)?.toDouble(),
        dossierId: row['DossierID'] as int,
        tarif: row['code_tarif'] as String,
      );

      return ActiviteFacturable(
        activite: activite,
        tarifHoraire: (row['tarif_horaire'] as num).toDouble(),
        montantFacturable: (row['montant_facturable'] as num).toDouble(),
        descriptionTarif: (row  ['description_tarif'] as String),
        groupeTarif: (row['groupe_tarif'] as String),
        ordreTarif: (row['ordre_tarif'] as int?),
      );
    }).toList();
  }
}
