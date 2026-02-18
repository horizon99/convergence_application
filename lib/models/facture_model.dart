class Facture {
  final int? idFacture;
  final DateTime dateOp;
  final int dossierID;
  final int contactID;
  final String? titre;
  final String? libelle;
  final String? conditions;
  final String? contenu;
  final double? honoraires;
  final double? participation;
  final int? tauxParticipation;
  final double? frais;
  final double? total;
  final DateTime? activitesDu;
  final DateTime? activiteAu;
  final bool paye;

  Facture({
    required this.idFacture,
    required this.dateOp,
    required this.dossierID,
    required this.contactID,
    required this.paye,
    this.titre,
    this.libelle,
    this.conditions,
    this.contenu,
    this.honoraires,
    this.tauxParticipation,
    this.frais,
    this.total,
    this.participation,
    this.activitesDu,
    this.activiteAu,
  });

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      idFacture: map['id_facture'] as int,
      dateOp: DateTime.parse(map['date_facture']),
      dossierID: map['dossier_id'] as int,
      contactID: map['contact_id'] as int,
      titre: map['titre'] as String?,
      libelle: map['libelle'] as String?,
      conditions: map['conditions'] as String?,
      contenu: map['contenu'] as String?,
      honoraires: map['montant_honoraires'] != null ? (map['montant_honoraires'] as num).toDouble() : 0.0,
      frais: map['montant_frais'] != null ? (map['montant_frais'] as num).toDouble() : 0.0,
      total: map['montant_total'] != null ? (map['montant_total'] as num).toDouble() : 0.0,
      participation: map['montant_participation'] != null ? (map['montant_participation'] as num).toDouble() : 0.0,
      tauxParticipation: map['taux_participation'] as int?,
      paye: map['paye'] == 1,
      activitesDu: map['activites_du'] != null
          ? DateTime.parse(map['activites_du'])
          : null,
      activiteAu: map['activites_au'] != null
          ? DateTime.parse(map['activites_au'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'date_facture': dateOp.toIso8601String(),
      'dossier_id': dossierID,
      'contact_id': contactID,
      'titre': titre,
      'libelle': libelle,
      'conditions': conditions,
      'contenu': contenu,
      'montant_honoraires': honoraires,
      'montant_frais': frais,
      'montant_total': total,
      'montant_participation': participation,
      'taux_participation': tauxParticipation,
      'paye': paye ? 1 : 0,
      'activites_du': activitesDu?.toIso8601String(),
      'activites_au': activiteAu?.toIso8601String(),
    };
  }
}

class FacturesForDropdown {
  final int idFacture;
  final DateTime dateOp;
  final String nomContact;
  final double montantParticipation;
  final bool paye;

  FacturesForDropdown({
    required this.idFacture,
    required this.dateOp,
    required this.nomContact,
    required this.montantParticipation,
    required this.paye,
  });

  factory FacturesForDropdown.fromMap(Map<String, dynamic> map) {
    return FacturesForDropdown(
      idFacture: map['id_facture'] as int,
      dateOp: DateTime.parse(map['date_facture']),
      nomContact: map['contact_name'] as String,
      montantParticipation: map['montant_participation'] != null ? (map['montant_participation'] as num).toDouble() : 0.0,
      paye: map['paye'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'date_facture': dateOp.toIso8601String(),
      'contact_name': nomContact,
      'montant_participation': montantParticipation,
      'paye': paye ? 1 : 0,
    };
  }
}

class FacturePaiement {
  final int idFacture;
  final int idDossier;
  final int idContact;
  final DateTime dateOp;
  final String? libelle;
  final DateTime? activitesDu;
  final DateTime? activitesAu;
  final double montantFacture;
  final double montantEncaisse;
  final double soldeRestant;
  final bool paye;

  FacturePaiement({
    required this.idFacture,
    required this.idDossier,
    required this.idContact,
    required this.dateOp,
    this.libelle,
    this.activitesDu,
    this.activitesAu,
    required this.montantFacture,
    required this.montantEncaisse,
    required this.soldeRestant,
    required this.paye,
  });

  factory FacturePaiement.fromMap(Map<String, dynamic> map) {
    return FacturePaiement(
      idFacture: map['id_facture'] as int,
      idDossier: map['dossier_id'] as int,
      idContact: map['contact_id'] as int,
      dateOp: DateTime.parse(map['date_facture']),
      activitesDu: map['activites_du'] != null ? DateTime.parse(map['activites_du']) : DateTime.now(),
      activitesAu: map['activites_au'] != null ? DateTime.parse(map['activites_au']) : DateTime.now(),
      libelle: map['libelle'] as String?,
      montantFacture: map['montant_facture'] != null ? (map['montant_facture'] as num).toDouble() : 0.0,
      montantEncaisse: map['montant_encaisse'] != null ? (map['montant_encaisse'] as num).toDouble() : 0.0,
      soldeRestant: map['solde_restant'] != null ? (map['solde_restant'] as num).toDouble() : 0.0,
      paye: map['paye'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'date_facture': dateOp.toIso8601String(),
      'libelle': libelle,
      'dossier_id': idDossier,
      'contact_id': idContact,
      'activites_du': activitesDu?.toIso8601String(),
      'activites_au': activitesAu?.toIso8601String(),
      'montant_facture': montantFacture,
      'montant_encaisse': montantEncaisse,
      'solde_restant': soldeRestant,
      'paye': paye ? 1 : 0,
    };
  }
}
