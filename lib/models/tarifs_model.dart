class ModeleTarif {
  final int? idTarif;
  final String groupeTarif;
  final String codeTarif;
  final int ordreTarif;
  final String? descriptionTarif;
  final String? texteFacture;
  final int tarifHoraire;

  ModeleTarif({
    required this.idTarif,
    required this.groupeTarif,
    required this.codeTarif,
    required this.ordreTarif,
    this.descriptionTarif,
    this.texteFacture,
    required this.tarifHoraire,
  });
    
       
    factory ModeleTarif.fromMap(Map<String, dynamic> map) {
    return ModeleTarif(
      idTarif: map['id_tarif'],
      groupeTarif: map['groupe'],
      codeTarif: map['code'],
      ordreTarif: map['ordre'],
      descriptionTarif: map['description'],
      texteFacture: map['texte_facture'],
      tarifHoraire: map['tarif_horaire'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_tarif': idTarif,
      'groupe': groupeTarif,
      'code': codeTarif, 
      'ordre': ordreTarif,
      'description': descriptionTarif,
      'texte_facture': texteFacture,
      'tarif_horaire': tarifHoraire,
    };
  }
}