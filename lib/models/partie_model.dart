class Partie {
  final int? idPartie;
  final int contactId;
  final int dossierId;
  final String? attention;
  final String? role;
  final String? concerne;
  final int? participation;

  Partie({
    this.idPartie,
    required this.contactId,
    required this.dossierId,
    this.attention,
    this.role,
    this.concerne,
    this.participation,
  });

  factory Partie.fromMap(Map<String, dynamic> map) {
    return Partie(
      idPartie: map['id_partie'] as int,
      contactId: map['contact_id'] as int,
      dossierId: map['dossier_id'] as int,
      attention: map['attention'] as String?,
      role: map['role'] as String?,
      concerne: map['concerne'] as String?,
      participation: map['participation'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'contact_id': contactId,
      'dossier_id': dossierId,
      'attention': attention,
      'role': role,
      'concerne': concerne,
      'participation': participation,
    };
    if (idPartie != null) {
      map['id_partie'] = idPartie;
    }
    return map;
  }

  Partie copyWith({
    int? idPartie,
    int? contactId,
    String? role,
    String? attention,
    String? concerne,
    int? participation,
  }) {
    return Partie(
      idPartie: idPartie ?? this.idPartie,
      dossierId: dossierId,
      contactId: contactId ?? this.contactId,
      role: role ?? this.role,
      attention: attention ?? this.attention,
      concerne: concerne ?? this.concerne,
      participation: participation,
    );
  }
}
