class Activite {
  final int idActivite;
  final DateTime dateOp;
  final String libelle;
  final double? minutes;
  final double? frais;
  final int dossierId;
  final int tarif;

  Activite({
    required this.idActivite,
    required this.dateOp,
    required this.libelle,
    this.minutes,
    this.frais,
    required this.dossierId,
    this.tarif = 1,
  });

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      idActivite: map['ID_Activite'],
      dateOp: DateTime.parse(map['DateOp']),
      libelle: map['Libelle'],
      minutes: map['Minutes']?.toDouble(),
      frais: map['Frais']?.toDouble(),
      dossierId: map['DossierID'],
      tarif: map['Tarif'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Activite': idActivite,
      'DateOp': dateOp.toIso8601String(),
      'Libelle': libelle,
      'Minutes': minutes,
      'Frais': frais,
      'DossierID': dossierId,
      'Tarif': tarif,
    };
  }
}