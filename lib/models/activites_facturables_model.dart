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
      tarifHoraire: map['tarif_horaire'] != null ? (map['tarif_horaire'] as num).toDouble() : 0.0,
      montantFacturable: map['montant_facturable'] != null ? (map['montant_facturable'] as num).toDouble() : 0.0,
      descriptionTarif: map['description_tarif'] ?? '',
      groupeTarif: map['groupe_tarif'],
      ordreTarif: map['ordre_tarif'] != null ? (map['ordre_tarif'] as int) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...activite.toMap(),
      'tarif_horaire': tarifHoraire,
      'montant_facturable': montantFacturable,
      'description_tarif': descriptionTarif,
      'groupe_tarif': groupeTarif,
      'ordre_tarif': ordreTarif,
    };
  }
}
