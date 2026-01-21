import 'package:flutter/material.dart';

class Dossier {
  final int id;
  final String libelle;
  final int tarif;
  final double? tva;
  final int prioriteId;
  final String prioriteLabel;
  final String? afaire;
  final DateTime? dateCreation;
  final DateTime? dateArchive;
  final int? noArchive;
  final bool archive;
  final String? refTribunal;

  Dossier({
    required this.id,
    required this.libelle,
    required this.tarif,
    this.tva,
    required this.prioriteId,
    required this.prioriteLabel,
    required this.afaire,
    this.dateCreation,
    this.dateArchive,
    this.noArchive,
    required this.archive,
    required this.refTribunal,
  });

  factory Dossier.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString();

      // Try ISO parse first
      final iso = DateTime.tryParse(s);
      if (iso != null) return iso;

      // Try common localized formats like dd.MM.yyyy or dd/MM/yyyy or dd-MM-yyyy
      final parts = s.split(RegExp(r'[.\-\/]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) return DateTime(y, m, d);
      }

      return null;
    }

    return Dossier(
      id: map['ID_Dossier'],
      libelle: map['Libelle'],
      tarif: map['Tarif'],
      tva: map['TVA'] != null ? double.tryParse(map['TVA'].toString()) : null,
      prioriteId: map['Priorite'],
      prioriteLabel: map['lblPriorite'],
      afaire: map['Afaire'],
      dateCreation: parseDate(map['Date_creation']),
      dateArchive: parseDate(map['Date_archive']),
      noArchive: map['No_archive'],
      archive: map['Archive'] == 1,
      refTribunal: map['Ref_tribunal'],
    );
    
  }
   // 🎨 Couleur selon la priorité
  Color get prioriteColor {
    switch (prioriteLabel.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'a traiter':
        return Colors.orange;
      case 'en attente':
        return Colors.green;
      case 'a encaisser':
        return Colors.purple;
      case 'a archiver':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ⭐ Icône selon la priorité
  IconData get prioriteIcon {
    switch (prioriteLabel.toLowerCase()) {
      case 'urgent':
        return Icons.warning;
      case 'a traiter':
        return Icons.priority_high;
      case 'en attente':
        return Icons.low_priority;
      case 'a encaisser':
        return Icons.low_priority;
      case 'a archiver':
        return Icons.low_priority;
      default:
        return Icons.archive;
    }
  }
}
