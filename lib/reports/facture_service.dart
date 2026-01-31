import '../../models/activites_facturables_model.dart';
import '../../models/contacts_model.dart';
import '../../models/dossier_model.dart';
import '../../models/facture_contenu_model.dart';
import '../../models/mediateur_model.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../data/repositories/contacts_repository.dart';
import '../data/repositories/dossier_repository.dart';
import '../data/repositories/mediateur_repository.dart';
import '../data/repositories/partie_repository.dart';

class InvoiceData {
  final Dossier dossier;
  final Mediateur mediateur;
  final Contact client;
  final List<ActiviteFacturable> activities;
  final List<FactureContenu> content;

  InvoiceData({
    required this.dossier,
    required this.mediateur,
    required this.client,
    required this.activities,
    required this.content,
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
    );
  }
}
