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
      idFacture: map['ID_Facture'],
      dateOp: DateTime.parse(map['DateOp']),
      dossierID: map['DossierID'],
      contactID: map['ContactID'],
      titre: map['Titre'],
      libelle: map['Libelle'],
      conditions: map['Conditions'],
      contenu: map['Contenu'],
      facturable: map['Facturable'],
      montant: map['Montant'],
      participation: map['Participation'],
      activitesDu: map['ActivitesDu'] != null
          ? DateTime.parse(map['ActivitesDu'])
          : null,
      activiteAu: map['ActiviteAu'] != null
          ? DateTime.parse(map['ActiviteAu'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Facture': idFacture,
      'DateOp': dateOp.toIso8601String(),
      'DossierID': dossierID,
      'ContactID': contactID,
      'Titre': titre,
      'Libelle': libelle,
      'Conditions': conditions,
      'Contenu': contenu,
      'Facturable': facturable,
      'Montant': montant,
      'Participation': participation,
      'ActivitesDu': activitesDu?.toIso8601String(),
      'ActiviteAu': activiteAu?.toIso8601String(),
    };
  }
}
