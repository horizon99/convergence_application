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

  static const List<String> titreContact = [
    'Monsieur',
    'Madame',
    'Maître',
  ];

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

  static Future<void> launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
