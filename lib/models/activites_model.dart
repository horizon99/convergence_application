class Activite {
  final int? idActivite;
  final DateTime dateOp;
  final String libelle;
  final int? minutes;
  final double? frais;
  final int dossierId;
  final String tarif;

  Activite({
    required this.idActivite,
    required this.dateOp,
    required this.libelle,
    this.minutes,
    this.frais,
    required this.dossierId,
    this.tarif = '',
  });

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      idActivite: map['ID_Activite'],
      dateOp: DateTime.parse(map['DateOp']),
      libelle: map['Libelle'],
      minutes: map['Minutes'] != null ? (map['Minutes'] as num).toInt() : null,
      frais: map['Frais'] != null ? (map['Frais'] as num).toDouble() : null,
      dossierId: map['DossierID'],
      tarif: map['Tarif']?.toString() ?? '',
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

  Activite copyWith({
    int? idActivite,
    DateTime? dateOp,
    String? libelle,
    int? minutes,
    double? frais,
    int? dossierId,
    String? tarif,
  }) {
    return Activite(
      idActivite: idActivite ?? this.idActivite,
      dateOp: dateOp ?? this.dateOp,
      libelle: libelle ?? this.libelle,
      minutes: minutes ?? this.minutes,
      frais: frais ?? this.frais,
      dossierId: dossierId ?? this.dossierId,
      tarif: tarif ?? this.tarif,
    );
  }

}