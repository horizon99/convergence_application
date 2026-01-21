class Contact {
  final int? id;
  final String nom;
  final String? prenom;
  final String? adresse;
  final String? titre;
  final String? telFixe;
  final String? telMobile;
  final String? email;
  final String? appelLettre;
  final String? finLettre;
  final String? remarques;
  final String? adresse2;
  final String? noRue;
  final String? noPostal;
  final String? localite;

  Contact({
    required this.id,
    required this.nom,
    this.prenom,
    this.adresse,
    this.titre,
    this.telFixe,
    this.telMobile,
    this.email,
    this.appelLettre,
    this.finLettre,
    this.remarques,
    this.adresse2,
    this.noRue,
    this.noPostal,
    this.localite,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['ID_Contact'],
      nom: map['Nom'],
      prenom: map['Prenom'] ?? 'NULL',
      adresse: map['Adresse'] ?? 'NULL',
      titre: map['Titre'] ?? 'NULL',
      telFixe: map['Tel_fixe'] ?? 'NULL',
      telMobile: map['Tel_mobile'] ?? 'NULL',
      email: map['Email'] ?? 'NULL',
      appelLettre: map['Appel_lettre'] ?? 'NULL',
      finLettre: map['Fin_lettre'] ?? 'NULL',
      remarques: map['Remarques'] ?? 'NULL',
      adresse2: map['Adresse2'] ?? 'NULL',
      noRue: map['NoRue'] ?? 'NULL',
      noPostal: map['NoPostal'] ?? 'NULL',
      localite: map['Localite'] ?? 'NULL',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Contact': id,
      'Nom': nom,
      'Prenom': prenom,
      'Adresse': adresse,
      'Titre': titre,
      'Tel_fixe': telFixe,
      'Tel_mobile': telMobile,
      'Email': email,
      'Appel_lettre': appelLettre,
      'Fin_lettre': finLettre,
      'Remarques': remarques,
      'Adresse2': adresse2,
      'NoRue': noRue,
      'NoPostal': noPostal,
      'Localite': localite,
    };
  }

  Contact copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? adresse,
    String? titre,
    String? telFixe,
    String? telMobile,
    String? email,
    String? appelLettre,
    String? finLettre,
    String? remarques,
    String? adresse2,
    String? noRue,
    String? noPostal,
    String? localite,
  }) {
    return Contact(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      adresse: adresse ?? this.adresse,
      titre: titre ?? this.titre,
      telFixe: telFixe ?? this.telFixe,
      telMobile: telMobile ?? this.telMobile,
      email: email ?? this.email,
      appelLettre: appelLettre ?? this.appelLettre,
      finLettre: finLettre ?? this.finLettre,
      remarques: remarques ?? this.remarques,
      adresse2: adresse2 ?? this.adresse2,
      noRue: noRue ?? this.noRue,
      noPostal: noPostal ?? this.noPostal,
      localite: localite ?? this.localite,
    );
  }

  String get nomPrenom => prenom?.isNotEmpty == true ? '$nom $prenom' : nom;
}
