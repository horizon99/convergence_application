import 'activites_model.dart';

class ActiviteFacturable {
  final Activite activite;
  final double tarifHoraire;
  final double montantFacturable;
  final String descriptionTarif;
  final String? groupeTarif;
  final int? ordreTarif;

  ActiviteFacturable({
    required this.activite,
    required this.tarifHoraire,
    required this.montantFacturable,
    required this.descriptionTarif,
    required this.groupeTarif,
    required this.ordreTarif,
  });

    factory ActiviteFacturable.fromMap(Map<String, dynamic> map) {
    return ActiviteFacturable(
      activite: Activite.fromMap(map), 
      tarifHoraire: map['TarifHoraire'] != null ? (map['TarifHoraire'] as num).toDouble() : 0.0,
      montantFacturable: map['MontantFacturable'] != null ? (map['MontantFacturable'] as num).toDouble() : 0.0,
      descriptionTarif: map['DescriptionTarif'] ?? '',
      groupeTarif: map['GroupeTarif'],
      ordreTarif: map['OrdreTarif'] != null ? (map['OrdreTarif'] as int) : null,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...activite.toMap(),
      'TarifHoraire': tarifHoraire,
      'MontantFacturable': montantFacturable,
      'DescriptionTarif': descriptionTarif,
      'GroupeTarif': groupeTarif,
      'OrdreTarif': ordreTarif,
    };
  }
}
