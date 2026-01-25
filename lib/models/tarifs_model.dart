class ModeleTarif {
  final int? idTarif;
  final String groupeTarif;
  final String codeTarif;
  final int ordreTarif;
  final String? descriptionTarif;
  final int tarifHoraire;

  ModeleTarif({
    required this.idTarif,
    required this.groupeTarif,
    required this.codeTarif,
    required this.ordreTarif,
    this.descriptionTarif,
    required this.tarifHoraire,
  });
    
       
    factory ModeleTarif.fromMap(Map<String, dynamic> map) {
    return ModeleTarif(
      idTarif: map['ID_ModeleTarif'],
      groupeTarif: map['Groupe'],
      codeTarif: map['Code'],
      ordreTarif: map['Ordre'],
      descriptionTarif: map['Description'],
      tarifHoraire: map['Tarif'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_ModeleTarif': idTarif,
      'Groupe': groupeTarif,
      'Code': codeTarif, 
      'Ordre': ordreTarif,
      'Description': descriptionTarif,
      'Tarif': tarifHoraire,
    };
  }
}