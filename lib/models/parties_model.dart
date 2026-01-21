class Parties {
  final int idPartie;
  final int contactId;
  final int dossierId;

  final String? attention;
  final String? role;
  final String? concerne;
  final int? facturable;
  final String? telFixe;
  final String? telMobile; 
  final String? email;

  // 🔗 Champ enrichi depuis contacts
  final String nomPrenom;

  Parties({
    required this.idPartie,
    required this.contactId,
    required this.dossierId,
    required this.nomPrenom,
    this.attention,
    this.role,
    this.concerne,
    this.facturable,
    this.telFixe,
    this.telMobile,
    this.email,
  });

  factory Parties.fromMap(Map<String, dynamic> map) {
    return Parties(
      idPartie: map['ID_Partie'] as int,
      contactId: map['ContactID'] as int,
      dossierId: map['DossierID'] as int,
      nomPrenom: map['NomPrenom'] as String,

      attention: map['Attention'] as String?,
      role: map['Role'] as String?,
      concerne: map['Concerne'] as String?,
      facturable: map['Facturable'] as int?,
      telFixe: map['Tel_fixe'] as String?,
      telMobile: map['Tel_mobile'] as String?,
      email: map['Email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Partie': idPartie,
      'ContactID': contactId,
      'DossierID': dossierId,
      'Attention': attention,
      'Role': role,
      'Concerne': concerne,
      'Facturable': facturable,
    };
  }
}
