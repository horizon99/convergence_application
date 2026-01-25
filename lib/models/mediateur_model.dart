import 'dart:typed_data';

class Mediateur {
  final int idMediateur;
  final String? nom;
  final String? titre;
  final String? adresse;
  final bool? tva;
  final String? enTete;
  final String? localite;
  final Uint8List? logo;
  final String? enTetePapier;
  final String? factureAdresse;
  final String? factureNoRue;
  final String? factureNoPostal;
  final String? factureLocalite;
  final String? telephone;
  final String? iban;
  final String? email;

  Mediateur({
    required this.idMediateur,
    this.nom,
    this.titre,
    this.adresse,
    this.tva,
    this.enTete,
    this.localite,
    this.logo,
    this.enTetePapier,
    this.factureAdresse,
    this.factureNoRue,
    this.factureNoPostal,
    this.factureLocalite,
    this.telephone,
    this.iban,
    this.email
  });

  factory Mediateur.fromMap(Map<String, dynamic> map) {
    return Mediateur(
      idMediateur: map['ID_Mediateur'],
      nom: map['Nom'],
      titre: map['Titre'],
      adresse: map['Adresse'],
      tva: map['TVA'] == 1 ? true : false,
      enTete: map['EnTete'],
      localite: map['Localite'],
      logo: map['Logo'],
      enTetePapier: map['EnTetePapier'],
      factureAdresse: map['FactureAdresse'],
      factureNoRue: map['FactureNoRue'],
      factureNoPostal: map['FactureNoPostal'],
      factureLocalite: map['FactureLocalite'],
      telephone: map['Telephone'],
      iban: map['IBAN'],
      email: map['Email']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'ID_Mediateur': idMediateur,
      'Nom': nom,
      'Titre': titre,
      'Adresse': adresse,
      'TVA': tva ?? false ? 1 : 0,
      'EnTete': enTete,
      'Localite': localite,
      'Logo': logo,
      'EnTetePapier': enTetePapier,
      'FactureAdresse': factureAdresse,
      'FactureNoRue': factureNoRue,
      'FactureNoPostal': factureNoPostal,
      'FactureLocalite': factureLocalite,
      'Telephone': telephone,
      'IBAN': iban,
      'Email': email
    };
  }
}
