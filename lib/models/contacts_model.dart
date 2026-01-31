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
      id: map['id_contact'],
      nom: map['nom'],
      prenom: map['prenom'] ?? 'NULL',
      adresse: map['adresse'] ?? 'NULL',
      titre: map['titre'] ?? 'NULL',
      telFixe: map['tel_fixe'] ?? 'NULL',
      telMobile: map['tel_mobile'] ?? 'NULL',
      email: map['email'] ?? 'NULL',
      appelLettre: map['appel_lettre'] ?? 'NULL',
      finLettre: map['fin_lettre'] ?? 'NULL',
      remarques: map['remarques'] ?? 'NULL',
      adresse2: map['adresse2'] ?? 'NULL',
      noRue: map['no_rue'] ?? 'NULL',
      noPostal: map['no_postal'] ?? 'NULL',
      localite: map['localite'] ?? 'NULL',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_contact': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'titre': titre,
      'tel_fixe': telFixe,
      'tel_mobile': telMobile,
      'email': email,
      'appel_lettre': appelLettre,
      'fin_lettre': finLettre,
      'remarques': remarques,
      'adresse2': adresse2,
      'no_rue': noRue,
      'no_postal': noPostal,
      'localite': localite,
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
