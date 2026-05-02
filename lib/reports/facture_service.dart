import 'dart:convert';
import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

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
import '../reports/facture_report.dart';
import '../reports/activites_facturables_report.dart';
import '../reports/qr_bill_generator.dart';
import '../reports/qr_bill.dart';

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
  static bool _isGeneratingPdf = false;

  Future<InvoiceData> getInvoiceData(
    int dossierId,
    DateTime dateDu,
    DateTime dateAu,
  ) async {
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

    final client = await ContactsRepository().getContactById(
      clientPartie.contactId,
    );
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
    if (client == null) {
      throw Exception('Détails du contact client non trouvés');
    }

    List<FactureContenu> content = [];
    if (facture.contenu != null && facture.contenu!.isNotEmpty) {
      try {
        final decoded = jsonDecode(facture.contenu!) as List<dynamic>;
        content = decoded.map((e) {
          return FactureContenu(
            codeTarif: e['codeTarif']?.toString(),
            texteFacture: e['texteFacture']?.toString(),
            montantTarif: (e['montantTarif'] != null)
                ? (e['montantTarif'] as num).toDouble()
                : null,
            ordreTarif: e['ordreTarif'] != null
                ? (e['ordreTarif'] as num).toInt()
                : null,
            totalMinutes: e['totalMinutes'] != null
                ? (e['totalMinutes'] as num).toInt()
                : null,
            totalFrais: (e['totalFrais'] != null)
                ? (e['totalFrais'] as num).toDouble()
                : null,
            totalHonoraires: (e['totalHonoraires'] != null)
                ? (e['totalHonoraires'] as num).toDouble()
                : null,
          );
        }).toList();
      } catch (_) {
        content = [];
      }
    } else {
      // fallback: build content from activities if activitesDu/Au present
      if (facture.activitesDu != null && facture.activiteAu != null) {
        content = await ActivitesFacturablesRepository().getMontantsFacturables(
          facture.dossierID,
          dateDu: facture.activitesDu,
          dateAu: facture.activiteAu,
        );
      }
    }

    List<ActiviteFacturable> activities = [];
    if (facture.activitesDu != null && facture.activiteAu != null) {
      activities = await ActivitesFacturablesRepository()
          .getActivitesFacturables(
            facture.dossierID,
            dateDu: facture.activitesDu,
            dateAu: facture.activiteAu,
          );
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

  Future<void> generateFacturePDF(Map<String, Object> map, {
    required int idFacture,
    required bool afficherFacture,
    required bool afficherQrCode,
    required bool afficherReleveActivites,
    required bool afficherFrais,
    required bool afficherMontants,
    required double montantFacture,
    required List<ActiviteFacturable> activites,
    required DateTime dateDu,
    required DateTime dateAu,
    required int idDossier,
  }) async {
    if (_isGeneratingPdf) {
      throw Exception('Une generation PDF est deja en cours.');
    }
    _isGeneratingPdf = true;

    sf.PdfDocument? docFacture;
    sf.PdfDocument? docQrCode;
    sf.PdfDocument? docReleve;
    sf.PdfDocument? result;

    try {
      final String dossierLibelle = 'Dossier $idDossier'; // TODO

      // Generate selected PDFs
      console.log('Debut de la generation de la facture');

      if (afficherFacture) {
        final pwFacture = await FactureReport().generate(idFacture);
        final bytesFacture = await pwFacture.save();
        docFacture = sf.PdfDocument(inputBytes: bytesFacture);
      }

      console.log('Debut de la generation de la part QR code');

      if (afficherQrCode) {
        final invoiceData = await getInvoiceDataFromFacture(idFacture);
        final qrBytes = await generateQRBill(invoiceData, montantFacture);
        if (qrBytes != null && qrBytes.isNotEmpty) {
          docQrCode = sf.PdfDocument(inputBytes: qrBytes);
        } else {
          console.log('QR code PDF non genere (contenu invalide ou vide).');
        }
      }

      console.log('Debut de la generation du releve d\'activites');

      if (afficherReleveActivites) {
        final pwReleve = await ActivitesFacturablesReport().buildReleveActivitesPdf(
          activites: activites,
          dateDu: dateDu,
          dateAu: dateAu,
          dossierLibelle: dossierLibelle,
          afficherFrais: afficherFrais,
          afficherMontants: afficherMontants,
        );
        final bytesReleve = await pwReleve.save();
        docReleve = sf.PdfDocument(inputBytes: bytesReleve);
      }

      result = sf.PdfDocument();
      sf.PdfSection? section;

      console.log(
        'PDF fusionne initialise: ${result.pages.count} pages avant fusion',
      );

      if (docFacture != null) {
        for (int i = 0; i < docFacture.pages.count; i++) {
          final sf.PdfTemplate template = docFacture.pages[i].createTemplate();
          if (section == null || section.pageSettings.size != template.size) {
            section = result.sections!.add();
            section.pageSettings.size = template.size;
            section.pageSettings.margins.all = 0;
          }

          section.pages.add().graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
          );
        }
      }

      if (docQrCode != null && docQrCode.pages.count > 0) {
        final sf.PdfTemplate template = docQrCode.pages[0].createTemplate();

        if (result.pages.count == 0) {
          section = result.sections!.add();
          section.pageSettings.size = template.size;
          section.pageSettings.margins.all = 0;
          section.pages.add().graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
          );
        } else {
          result.pages[0].graphics.drawPdfTemplate(
            template,
            const Offset(0, 520),
          );
        }
      }

      if (docReleve != null) {
        for (int i = 0; i < docReleve.pages.count; i++) {
          final sf.PdfTemplate template = docReleve.pages[i].createTemplate();
          if (section == null || section.pageSettings.size != template.size) {
            section = result.sections!.add();
            section.pageSettings.size = template.size;
            section.pageSettings.margins.all = 0;
          }

          section.pages.add().graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
          );
        }
      }

      if (result.pages.count == 0) {
        throw Exception('Aucune page PDF n\'a pu etre generee.');
      }

      final mergedBytes = await result.save();

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'FA_${idDossier.toString()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(mergedBytes, flush: true);

      final openResult = await OpenFilex.open(file.path);
      console.log('PDF fusionne genere : ${file.path} (${openResult.type})');

    //if (_preparerEmail) {
    //final invoiceData = await FactureService().getInvoiceDataFromFacture(widget.idFacture);
    //if (invoiceData.client.email == null || invoiceData.client.email!.isEmpty) {
    //  console.log('Aucune adresse e-mail trouvée pour le client. Impossible de préparer le courriel.');
    //  return;
    //}
    //AppHelper.launchEmail(
    //    address: invoiceData.client.email ?? '',
    //    subject: widget.dossierLibelle,
    //    body: 'Je me permets de vous transmettre ci-joint ma facture relative aux récentes activités. N’hésitez pas à me contacter si vous avez des questions ou besoin de précisions supplémentaires.',
    //    attachmentPath: file.path);
    //}
      return;
    } catch (e, st) {
      console.log('Erreur generation PDF: $e\n$st');
      rethrow;
    } finally {
      docFacture?.dispose();
      docQrCode?.dispose();
      docReleve?.dispose();
      result?.dispose();
      _isGeneratingPdf = false;
    }
  }

  Future<Uint8List?> generateQRBill(
    InvoiceData invoiceData,
    double montantFacture,
  ) async {
    QRBill qrBill = QRBill();
    qrBill.setVersion(2.00);
    qrBill.setQrType("SPC");
    qrBill.setIBAN(invoiceData.mediateur.iban);
    qrBill.setActor(
      typeId: QRBill.actorCR,
      addressType: QRBill.addTypeStructured,
      name: invoiceData.mediateur.nom,
      address1: invoiceData.mediateur.factureAdresse,
      address2: invoiceData.mediateur.factureNoRue,
      postalcode: invoiceData.mediateur.factureNoPostal,
      location: invoiceData.mediateur.factureLocalite,
      country: "CH",
    );
    qrBill.setActor(
      typeId: QRBill.actorUDR,
      addressType: QRBill.addTypeStructured,
      name: invoiceData.client.nomPrenom,
      address1: invoiceData.client.adresse,
      address2: invoiceData.client.noRue,
      postalcode: invoiceData.client.noPostal,
      location: invoiceData.client.localite,
      country: "CH",
    );
    qrBill.setAmount(montantFacture);
    qrBill.setReference(QRBill.refTypeNON);
    qrBill.setAdditionalInfo("test");
    //bool isValid = qrBill.isValid();
    //console.log('QR Bill is valid: $isValid');

    BillGenerator bg = BillGenerator(language: BillGenerator.french);
    Uint8List? bill = await bg.generateInvoice(qrBill);
    //expect(bill == null, false);
    return bill;
  }
}
