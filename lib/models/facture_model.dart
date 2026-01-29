class Facture {
  final int idFacture;
  final DateTime dateOp;
  final int dossierID;
  final int contactID;
  final String? titre;
  final String? libelle;
  final String? conditions;
  final String? contenu;
  final double? facturable;
  final double? montant;
  final double? participation;
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
    this.facturable,
    this.montant,
    this.participation,
    this.activitesDu,
    this.activiteAu,
  });

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      idFacture: map['id_facture'],
      dateOp: DateTime.parse(map['date_op']),
      dossierID: map['dossier_id'],
      contactID: map['contact_id'],
      titre: map['titre'],
      libelle: map['libelle'],
      conditions: map['conditions'],
      contenu: map['contenu'],
      facturable: map['montant_facture'],
      montant: map['montant_total'],
      participation: map['participation'],
      activitesDu: map['activites_du'] != null
          ? DateTime.parse(map['activites_du'])
          : null,
      activiteAu: map['activite_au'] != null
          ? DateTime.parse(map['activite_au'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'date_op': dateOp.toIso8601String(),
      'dossier_id': dossierID,
      'contact_id': contactID,
      'titre': titre,
      'libelle': libelle,
      'conditions': conditions,
      'contenu': contenu,
      'montant_facture': facturable,
      'montant_total': montant,
      'participation': participation,
      'activites_du': activitesDu?.toIso8601String(),
      'activite_au': activiteAu?.toIso8601String(),
    };
  }
}
