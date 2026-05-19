import 'dart:typed_data';

class Mediateur {
  final int idMediateur;
  final String? nom;
  final String? titre;
  final String? adresse;
  final bool? tva;
  final String? enTeteRapport;
  final String? localite;
  final Uint8List? logo;
  final int? logoX;
  final int? logoY;
  final int? logoW;
  final int? logoH;
  final String? enTetePapier;
  final int? enTetePapierX;
  final int? enTetePapierY;
  final String? factureAdresse;
  final String? factureNoRue;
  final String? factureNoPostal;
  final String? factureLocalite;
  final String? factureLibelle;
  final String? factureConditions;
  final String? telephone;
  final String? iban;
  final String? email;

  Mediateur({
    required this.idMediateur,
    this.nom,
    this.titre,
    this.adresse,
    this.tva,
    this.enTeteRapport,
    this.localite,
    this.logo,
    this.logoX,
    this.logoY,
    this.logoW,
    this.logoH,
    this.enTetePapier,
    this.enTetePapierX,
    this.enTetePapierY,
    this.factureAdresse,
    this.factureNoRue,
    this.factureNoPostal,
    this.factureLocalite,
    this.factureLibelle,
    this.factureConditions,
    this.telephone,
    this.iban,
    this.email
  });

  factory Mediateur.fromMap(Map<String, dynamic> map) {
    return Mediateur(
      idMediateur: map['id_mediateur'],
      nom: map['nom'],
      titre: map['titre'],
      adresse: map['adresse'],
      tva: map['tva'] == 1 ? true : false,
      enTeteRapport: map['en_tete_rapport'],
      localite: map['localite'],
      logo: map['logo'],
      logoX: map['logo_x'],
      logoY: map['logo_y'],
      logoW: map['logo_w'],
      logoH: map['logo_h'],
      enTetePapier: map['en_tete_papier'],
      enTetePapierX: map['en_tete_papier_x'],
      enTetePapierY: map['en_tete_papier_y'],
      factureAdresse: map['facture_adresse'],
      factureNoRue: map['facture_no_rue'],
      factureNoPostal: map['facture_no_postal'],
      factureLocalite: map['facture_localite'],
      factureLibelle: map['facture_libelle'],
      factureConditions: map['facture_conditions'],
      telephone: map['telephone'],
      iban: map['iban'],
      email: map['email']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id_mediateur': idMediateur,
      'nom': nom,
      'titre': titre,
      'adresse': adresse,
      'tva': tva ?? false ? 1 : 0,
      'en_tete_rapport': enTeteRapport,
      'localite': localite,
      'logo': logo,
      'logo_x': logoX,
      'logo_y': logoY,
      'logo_w': logoW,
      'logo_h': logoH,
      'en_tete_papier': enTetePapier,
      'en_tete_papier_x': enTetePapierX,
      'en_tete_papier_y': enTetePapierY,
      'facture_adresse': factureAdresse,
      'facture_no_rue': factureNoRue,
      'facture_no_postal': factureNoPostal,
      'facture_localite': factureLocalite,
      'facture_libelle': factureLibelle,
      'facture_conditions': factureConditions,
      'telephone': telephone,
      'iban': iban,
      'email': email
    };
  }
}
