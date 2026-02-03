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

  Facture({
    required this.idFacture,
    required this.dateOp,
    required this.dossierID,
    required this.contactID,
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
      'activites_du': activitesDu?.toIso8601String(),
      'activites_au': activiteAu?.toIso8601String(),
    };
  }
}
