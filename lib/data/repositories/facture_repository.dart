import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/facture_model.dart';

class FactureRepository {
  Future<List<Facture>> getAllFactures() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query('factures');

    return result.map((e) => Facture.fromMap(e)).toList();
  }

  Future<List<Facture>> getFacturesFromDossier(int dossierId) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'factures',
      where: 'dossier_id = ?', 
      whereArgs: [dossierId],
    );

    return result.map((e) => Facture.fromMap(e)).toList();
  }

  Future<Facture?> getFactureById(int idFacture) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'factures',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Facture.fromMap(result.first);
  }

  Future<int> updateFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'factures',
      facture.toMap(),
      where: 'id_facture = ?',
      whereArgs: [facture.idFacture],
    );
  }

  Future<int> insertFacture(Facture facture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert('factures', facture.toMap());
  }

  Future<int> deleteFacture(int idFacture) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'factures',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
    );
  }

  Future<List<FacturePaiement>> getFacturesAndPaymentsDossier(int dossierId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT
    f.id_facture,
    f.dossier_id,
    f.contact_id,
    f.date_facture,
    f.libelle,
    f.montant_participation AS montant_facture,
    f.paye,

    COALESCE(SUM(
        CASE 
            WHEN e.nature = 'recette' THEN e.montant
            ELSE 0
        END
    ), 0) AS montant_encaisse,

    f.montant_participation
      - COALESCE(SUM(
            CASE 
                WHEN e.nature = 'recette' THEN e.montant
                ELSE 0
            END
        ), 0) AS solde_restant

FROM factures f

LEFT JOIN ecritures e
    ON e.facture_id = f.id_facture

WHERE f.dossier_id = ?

GROUP BY
    f.id_facture;

    ''', [dossierId]);

    // Traitez les résultats comme nécessaire, par exemple en les convertissant en objets Facture et Payment
    // Vous pouvez créer une classe combinée pour représenter les données de facture et de paiement si nécessaire

    return result.map((e) => FacturePaiement.fromMap(e)).toList();
  }

  Future<List<FacturePaiement>> getAllFacturesAndPayments() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT
    f.id_facture,
    f.date_facture,
    f.dossier_id,
    f.contact_id,
    f.libelle,
    f.montant_participation AS montant_facture,
    f.paye,

    COALESCE(SUM(
        CASE 
            WHEN e.nature = 'recette' THEN e.montant
            ELSE 0
        END
    ), 0) AS montant_encaisse,

    f.montant_participation
      - COALESCE(SUM(
            CASE 
                WHEN e.nature = 'recette' THEN e.montant
                ELSE 0
            END
        ), 0) AS solde_restant

FROM factures f

LEFT JOIN ecritures e
    ON e.facture_id = f.id_facture

GROUP BY
    f.id_facture;
    ''');

    // Traitez les résultats comme nécessaire, par exemple en les convertissant en objets Facture et Payment
    // Vous pouvez créer une classe combinée pour représenter les données de facture et de paiement si nécessaire

    return result.map((e) => FacturePaiement.fromMap(e)).toList();
  }

  Future<List<FacturesForDropdown>> getFacturesForDropdown() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT
        f.id_facture,
        f.date_facture,
        f.montant_participation,
        f.paye,
        COALESCE(c.nom, '') || CASE WHEN c.prenom IS NOT NULL AND c.prenom <> '' THEN ' ' || c.prenom ELSE '' END AS contact_name
      FROM factures f
      LEFT JOIN contacts c ON c.id_contact = f.contact_id
      ORDER BY f.paye
    ''');

    return result.map((e) => FacturesForDropdown.fromMap(e)).toList();
  }

}