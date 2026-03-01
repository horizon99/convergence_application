import 'package:convergence_application/models/facture_contenu_model.dart';

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
    try {
      final db = await DatabaseHelper.instance.database;

      String whereClause = 'dossier_id = ?';
      List<dynamic> whereArgs = [dossierId];

      if (dateDu != null) {
        whereClause += ' AND date_activite >= ?';
        whereArgs.add(dateDu.toIso8601String());
      }

      if (dateAu != null) {
        whereClause += ' AND date_activite <= ?';
        whereArgs.add(dateAu.toIso8601String());
      }

      final baseSql = '''
    SELECT
      a.id_activite,
      a.date_activite,
      a.libelle,
      a.minutes,
      a.frais,
      a.dossier_id,
      a.code_tarif,
      IFNULL(t.description, a.code_tarif) AS description_tarif,
      IFNULL(t.tarif_horaire, 0) AS tarif_horaire,
      (( IFNULL(a.minutes, 0) * IFNULL(t.tarif_horaire, 0)/60 ) + IFNULL(a.frais, 0)) AS montant_facturable,
      IFNULL(t.groupe, '-') AS groupe_tarif,
      IFNULL(t.ordre, 0) AS ordre_tarif
    FROM activites a
    LEFT OUTER JOIN tarifs t ON t.code = a.code_tarif
  ''';

      String sql = baseSql;
      if (whereClause.isNotEmpty) {
        sql += ' WHERE $whereClause';
      }
      sql += ' ORDER BY a.date_activite ASC';

      final result = await db.rawQuery(sql, whereArgs);

      return result.map((row) {
        final activite = Activite(
          idActivite: row['id_activite'] as int,
          dateActivite: DateTime.parse(row['date_activite'] as String),
          libelle: row['libelle'] as String,
          minutes: (row['minutes'] as num?)?.toInt(),
          frais: (row['frais'] as num?)?.toDouble(),
          dossierId: row['dossier_id'] as int,
          codeTarif: row['code_tarif'] as String,
        );

        return ActiviteFacturable(
          activite: activite,
          tarifHoraire: (row['tarif_horaire'] as num).toDouble(),
          montantFacturable: (row['montant_facturable'] as num).toDouble(),
          descriptionTarif: (row['description_tarif'] as String),
          groupeTarif: (row['groupe_tarif'] as String),
          ordreTarif: (row['ordre_tarif'] as int?),
        );
      }).toList();
    } catch (e) {
      //print('Exception in ActivitesFacturablesRepository.getActivitesFacturables: $e\n$st');
      rethrow;
    }
  }

  Future<List<FactureContenu>> getMontantsFacturables(
    int dossierId, {
    DateTime? dateDu,
    DateTime? dateAu,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      String whereClause = 'a.dossier_id = ?';
      List<dynamic> whereArgs = [dossierId];

      if (dateDu != null) {
        whereClause += ' AND a.date_activite >= ?';
        whereArgs.add(dateDu.toIso8601String());
      }

      if (dateAu != null) {
        whereClause += ' AND a.date_activite <= ?';
        whereArgs.add(dateAu.toIso8601String());
      }

      final baseSql = '''
  SELECT 
    t.code AS code_tarif,
    IFNULL(t.description, t.code) AS description_tarif,
    IFNULL(t.tarif_horaire, 0) AS tarif_horaire,
    IFNULL(t.ordre, 0) AS ordre_tarif,
    IFNULL(t.texte_facture, '') AS texte_facture,
  SUM(CASE WHEN a.minutes IS NOT NULL THEN a.minutes ELSE 0 END) AS total_minutes,
  SUM(CASE WHEN a.frais IS NOT NULL THEN a.frais ELSE 0 END) AS total_frais,
  SUM(CASE WHEN t.tarif_horaire IS NOT NULL THEN a.minutes * t.tarif_horaire ELSE 0 END)/60 AS total_honoraires
  FROM 
    activites a
    LEFT OUTER JOIN tarifs t ON t.code = a.code_tarif
    ''';

      String sql = baseSql;
      if (whereClause.isNotEmpty) {
        sql += ' WHERE $whereClause';
      }
        sql += ' GROUP BY t.code ORDER BY t.ordre ASC';

      final result = await db.rawQuery(sql, whereArgs);

      return result.map((row) {
        return FactureContenu(
          codeTarif: row['code_tarif'] as String? ?? '',
          texteFacture: row['texte_facture'] as String? ?? '',
          montantTarif: (row['tarif_horaire'] as num? ?? 0).toDouble(),
          ordreTarif: (row['ordre_tarif'] as int? ?? 0),
          totalFrais: (row['total_frais'] as num? ?? 0).toDouble(),
          totalHonoraires: (row['total_honoraires'] as num? ?? 0).toDouble(),
          totalMinutes: (row['total_minutes'] as num? ?? 0).toInt(),
        );
      }).toList();
    } catch (e) {
      //print('Exception in ActivitesFacturablesRepository.getMontantsFacturables: $e\n$st');
      rethrow;
    }
  }
}
