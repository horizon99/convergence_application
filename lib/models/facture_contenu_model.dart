class FactureContenu {
  final String? codeTarif;
  final String? descriptionTarif;
  final double? montantTarif;
  final int? ordreTarif;
  final int? totalMinutes;
  final double? totalFrais;
  final double? totalHonoraires;

  FactureContenu({
   this.codeTarif,
   this.descriptionTarif, 
   this.montantTarif, 
   this.ordreTarif, 
   this.totalMinutes, 
   this.totalFrais, 
   this.totalHonoraires,
  });

  factory FactureContenu.fromMap(Map<String, dynamic> map) {
    return FactureContenu(
      codeTarif: map['code_tarif'],
      descriptionTarif: map['description_tarif'],
      montantTarif: map['tarif_horaire'],
      ordreTarif: map['ordre_tarif'],
      totalMinutes: map['total_minutes'],
      totalFrais: map['total_Frais'],
      totalHonoraires: map['total_honoraires'],
    );
  }
}