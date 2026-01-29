class Parties {
  final int idPartie;
  final int contactId;
  final int dossierId;

  final String? attention;
  final String? role;
  final String? concerne;
  final int? participation;
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
    this.participation,
    this.telFixe,
    this.telMobile,
    this.email,
  });

  factory Parties.fromMap(Map<String, dynamic> map) {
    return Parties(
      idPartie: map['id_partie'] as int,
      contactId: map['contact_id'] as int,
      dossierId: map['dossier_id'] as int,
      nomPrenom: map['nom_prenom'] as String,

      attention: map['attention'] as String?,
      role: map['role'] as String?,
      concerne: map['concerne'] as String?,
      participation: map['participation'] as int?,
      telFixe: map['tel_fixe'] as String?,
      telMobile: map['tel_mobile'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_partie': idPartie,
      'contact_id': contactId,
      'dossier_id': dossierId,
      'attention': attention,
      'role': role,
      'concerne': concerne,
      'participation': participation,
    };
  }
}
