import 'package:url_launcher/url_launcher.dart';

class AppHelper {
  AppHelper._(); // empêche l'instanciation

  static const List<String> rolesParties = [
    'Client',
    'Avocat',
    'Autorité',
    'Assurance',
    'Famille',
    'Autre',
  ];

  static const List<String> titreContact = ['Monsieur', 'Madame', 'Maître'];

  static const List<String> appelLettreContact = [
    'Chère Madame',
    'Cher Monsieur',
    'Madame',
    'Monsieur',
    'Madame, Monsieur',
    'Madame la Présidente',
    'Monsieur le Président',
    'Maître',
    'Chère Consœur',
    'Cher Confrère',
  ];

  static const List<String> finLettreContact = [
    'chère Madame',
    'cher Monsieur',
    'Madame',
    'Monsieur',
    'Madame, Monsieur',
    'Madame la Présidente',
    'Monsieur le Président',
    'Maître',
    'chère Consœur',
    'cher Confrère',
  ];

  static Future<void> launchEmail({
    required String address,
    String? subject,
    String? body,
  }) async {
    final query = <String, String>{};
    if (subject != null && subject.isNotEmpty) query['subject'] = subject;
    if (body != null && body.isNotEmpty) query['body'] = body;

    final uri = Uri(
      scheme: 'mailto',
      path: address,
      queryParameters: query.isEmpty ? null : query,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static String minutesToHours(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDateString(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;

    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;

    final parts = v.split(RegExp(r'[.\-\/]'));
    if (parts.length >= 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }
    return null;
  }
}
