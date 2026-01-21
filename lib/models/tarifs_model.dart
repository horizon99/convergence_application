class ModeleTarif {
  final int id;
  final String modele;

  ModeleTarif({
    required this.id,
    required this.modele,
  });

  factory ModeleTarif.fromMap(Map<String, dynamic> map) {
    return ModeleTarif(
      id: map['ID_ModeleTarif'],
      modele: map['Modèle'] ?? 'NULL',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_ModeleTarif': id,
      'Modèle': modele,
    };
  }
}