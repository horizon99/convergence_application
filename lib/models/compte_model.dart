class Compte {
  final int? idCompte;
  final String numero;
  final String libelle;
  final String categorie;
  final bool actif;
  final int ordre;

  Compte({
    required this.idCompte,
    required this.numero,
    required this.libelle,
    required this.categorie,
    this.actif = true,
    this.ordre = 0,
  });

  factory Compte.fromMap(Map<String, dynamic> map) {
    bool parseActif(dynamic v) {
      if (v == null) return true;
      if (v is int) return v == 1;
      if (v is String) return v == '1';
      if (v is bool) return v;
      return true;
    }

    return Compte(
      idCompte: map['id_compte'],
      numero: map['numero']?.toString() ?? '',
      libelle: map['libelle']?.toString() ?? '',
      categorie: map['categorie']?.toString() ?? '',
      actif: parseActif(map['actif']),
      ordre: map['ordre'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_compte': idCompte,
      'numero': numero,
      'libelle': libelle,
      'categorie': categorie,
      'actif': actif ? 1 : 0,
      'ordre': ordre,
    };
  }

  Compte copyWith({
    int? idCompte,
    String? numero,
    String? libelle,
    String? categorie,
    bool? actif,
    int? ordre,
  }) {
    return Compte(
      idCompte: idCompte ?? this.idCompte,
      numero: numero ?? this.numero,
      libelle: libelle ?? this.libelle,
      categorie: categorie ?? this.categorie,
      actif: actif ?? this.actif,
      ordre: ordre ?? this.ordre,
    );
  }
}
