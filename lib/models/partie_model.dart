class Partie {
  final int? idPartie;
  final int contactId;
  final int dossierId;

  final String? attention;
  final String? role;
  final String? concerne;
  final int? facturable;

  Partie({
    this.idPartie,
    required this.contactId,
    required this.dossierId,
    this.attention,
    this.role,
    this.concerne,
    this.facturable,
  });

  factory Partie.fromMap(Map<String, dynamic> map) {
    return Partie(
      idPartie: map['ID_Partie'] as int,
      contactId: map['ContactID'] as int,
      dossierId: map['DossierID'] as int,

      attention: map['Attention'] as String?,
      role: map['Role'] as String?,
      concerne: map['Concerne'] as String?,
      facturable: map['Facturable'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'ContactID': contactId,
      'DossierID': dossierId,
      'Attention': attention,
      'Role': role,
      'Concerne': concerne,
      'Facturable': facturable,
    };
    if (idPartie != null) {
      map['ID_Partie'] = idPartie;
    }
    return map;
  }

  Partie copyWith({
    int? id,
    int? contactId,
    String? role,
    String? attention,
    String? concerne,
    int? facturable,
  }) {
    return Partie(
      idPartie: id ?? idPartie,
      dossierId: dossierId,
      contactId: contactId ?? this.contactId,
      role: role ?? this.role,
      attention: attention ?? this.attention,
      concerne: concerne ?? this.concerne,
      facturable: facturable ?? this.facturable,
    );
  }
}
