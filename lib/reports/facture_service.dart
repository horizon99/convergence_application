import 'dart:convert';

import '../../models/activites_facturables_model.dart';
import '../../models/contacts_model.dart';
import '../../models/dossier_model.dart';
import '../../models/facture_contenu_model.dart';
import '../../models/mediateur_model.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../data/repositories/contacts_repository.dart';
import '../data/repositories/dossier_repository.dart';
import '../data/repositories/facture_repository.dart';
import '../data/repositories/mediateur_repository.dart';
import '../data/repositories/partie_repository.dart';

class InvoiceData {
  final Dossier dossier;
  final Mediateur mediateur;
  final Contact client;
  final List<ActiviteFacturable> activities;
  final List<FactureContenu> content;
  final DateTime? dateDu;
  final DateTime? dateAu;

  InvoiceData({
    required this.dossier,
    required this.mediateur,
    required this.client,
    required this.activities,
    required this.content,
    this.dateDu,
    this.dateAu,
  });
}

class FactureService {
  Future<InvoiceData> getInvoiceData(
      int dossierId, DateTime dateDu, DateTime dateAu) async {
    final dossier = await DossierRepository().getDossierById(dossierId);
    if (dossier == null) {
      throw Exception('Dossier non trouvé');
    }

    final mediateur = await MediateurRepository().getMediateur();

    final parties = await PartieRepository().getPartieByDossier(dossierId);
    final clientPartie = parties.firstWhere(
      (p) => p.role == 'Client',
      orElse: () => throw Exception('Client non trouvé pour ce dossier'),
    );

    final client = await ContactsRepository().getContactById(clientPartie.contactId);
    if (client == null) {
      throw Exception('Détails du contact client non trouvés');
    }

    final content = await ActivitesFacturablesRepository()
        .getMontantsFacturables(dossierId, dateDu: dateDu, dateAu: dateAu);

    final activities = await ActivitesFacturablesRepository()
        .getActivitesFacturables(dossierId, dateDu: dateDu, dateAu: dateAu);

    return InvoiceData(
      dossier: dossier,
      mediateur: mediateur,
      client: client,
      activities: activities,
      content: content,
      dateDu: dateDu,
      dateAu: dateAu,
    );
  }

  Future<InvoiceData> getInvoiceDataFromFacture(int idFacture) async {
    final facture = await FactureRepository().getFactureById(idFacture);
    if (facture == null) throw Exception('Facture not found');

    final dossier = await DossierRepository().getDossierById(facture.dossierID);
    if (dossier == null) throw Exception('Dossier non trouvé');

    final mediateur = await MediateurRepository().getMediateur();

    final client = await ContactsRepository().getContactById(facture.contactID);
    if (client == null) throw Exception('Détails du contact client non trouvés');

    List<FactureContenu> content = [];
    if (facture.contenu != null && facture.contenu!.isNotEmpty) {
      try {
        final decoded = jsonDecode(facture.contenu!) as List<dynamic>;
        content = decoded.map((e) {
          return FactureContenu(
            codeTarif: e['codeTarif']?.toString(),
            texteFacture: e['texteFacture']?.toString(),
            montantTarif: (e['montantTarif'] != null) ? (e['montantTarif'] as num).toDouble() : null,
            ordreTarif: e['ordreTarif'] != null ? (e['ordreTarif'] as num).toInt() : null,
            totalMinutes: e['totalMinutes'] != null ? (e['totalMinutes'] as num).toInt() : null,
            totalFrais: (e['totalFrais'] != null) ? (e['totalFrais'] as num).toDouble() : null,
            totalHonoraires: (e['totalHonoraires'] != null) ? (e['totalHonoraires'] as num).toDouble() : null,
          );
        }).toList();
      } catch (_) {
        content = [];
      }
    } else {
      // fallback: build content from activities if activitesDu/Au present
      if (facture.activitesDu != null && facture.activiteAu != null) {
        content = await ActivitesFacturablesRepository()
            .getMontantsFacturables(facture.dossierID, dateDu: facture.activitesDu, dateAu: facture.activiteAu);
      }
    }

    List<ActiviteFacturable> activities = [];
    if (facture.activitesDu != null && facture.activiteAu != null) {
      activities = await ActivitesFacturablesRepository()
          .getActivitesFacturables(facture.dossierID, dateDu: facture.activitesDu, dateAu: facture.activiteAu);
    }

    return InvoiceData(
      dossier: dossier,
      mediateur: mediateur,
      client: client,
      activities: activities,
      content: content,
      dateDu: facture.activitesDu,
      dateAu: facture.activiteAu,
    );
  }
}
