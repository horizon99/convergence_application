class Ecriture {
  final int? id;
  final DateTime date;
  final int compteChargeProduitId;
  final int compteActifPassifId;
  final String nature; // 'recette' or 'depense'
  final double montant;
  final String? description;
  final int? factureId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ecriture({
    required this.id,
    required this.date,
    required this.compteChargeProduitId,
    required this.compteActifPassifId,
    required this.nature,
    required this.montant,
    this.description,
    this.factureId,
    this.createdAt,
    this.updatedAt,
  });

  factory Ecriture.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    return Ecriture(
      id: map['id'],
      date: parseDate(map['date']) ?? DateTime.now(),
      compteChargeProduitId: map['compte_charge_produit_id'],
      compteActifPassifId: map['compte_actif_passif_id'],
      nature: map['nature']?.toString() ?? 'recette',
      montant: map['montant'] is num ? (map['montant'] as num).toDouble() : double.tryParse(map['montant']?.toString() ?? '0') ?? 0.0,
      description: map['description'],
      factureId: map['facture_id'],
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'compte_charge_produit_id': compteChargeProduitId,
      'compte_actif_passif_id': compteActifPassifId,
      'nature': nature,
      'montant': montant,
      'description': description,
      'facture_id': factureId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Ecriture copyWith({
    int? id,
    DateTime? date,
    int? compteChargeProduitId,
    int? compteActifPassifId,
    String? nature,
    double? montant,
    String? description,
    int? factureId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ecriture(
      id: id ?? this.id,
      date: date ?? this.date,
      compteChargeProduitId: compteChargeProduitId ?? this.compteChargeProduitId,
      compteActifPassifId: compteActifPassifId ?? this.compteActifPassifId,
      nature: nature ?? this.nature,
      montant: montant ?? this.montant,
      description: description ?? this.description,
      factureId: factureId ?? this.factureId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
