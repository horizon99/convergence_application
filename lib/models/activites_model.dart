class Activite {
  final int? idActivite;
  final DateTime dateActivite;
  final String libelle;
  final int? minutes;
  final double? frais;
  final int dossierId;
  final String codeTarif;

  Activite({
    required this.idActivite,
    required this.dateActivite,
    required this.libelle,
    this.minutes,
    this.frais,
    required this.dossierId,
    this.codeTarif = '',
  });

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      idActivite: map['id_activite'],
      dateActivite: DateTime.parse(map['date_activite']),
      libelle: map['libelle'],
      minutes: map['minutes'] != null ? (map['minutes'] as num).toInt() : null,
      frais: map['frais'] != null ? (map['frais'] as num).toDouble() : null,
      dossierId: map['dossier_id'],
      codeTarif: map['code_tarif']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_activite': idActivite,
      'date_activite': dateActivite.toIso8601String(),
      'libelle': libelle,
      'minutes': minutes,
      'frais': frais,
      'dossier_id': dossierId,
      'code_tarif': codeTarif,
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
      dateActivite: dateActivite,
      libelle: libelle ?? this.libelle,
      minutes: minutes ?? this.minutes,
      frais: frais ?? this.frais,
      dossierId: dossierId ?? this.dossierId,
      codeTarif: codeTarif,
    );
  }

}