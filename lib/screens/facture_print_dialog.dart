import 'dart:developer' as console;
import 'dart:io';

import 'package:convergence_application/reports/facture_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../models/activites_facturables_model.dart';
import '../reports/activites_facturables_report.dart';
import '../reports/bill_generator.dart';
import '../reports/facture_report.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../reports/qr_bill.dart';

class FacturePrintDialog extends StatefulWidget {
  //final List<ActiviteFacturable> activites;
  final DateTime dateDu;
  final DateTime dateAu;
  final String dossierLibelle;
  final int idFacture;
  final int idDossier;
  final double montantFacture;

  const FacturePrintDialog({
    super.key,
    //required this.activites,
    required this.dateDu,
    required this.dateAu,
    required this.dossierLibelle,
    required this.idFacture,
    required this.idDossier,
    required this.montantFacture,
  });

  @override
  State<FacturePrintDialog> createState() => _FacturePrintDialogState();
}

class _FacturePrintDialogState extends State<FacturePrintDialog> {
  bool _afficherFacture = true;
  bool _afficherReleveActivites = true;
  bool _afficherFrais = true;
  bool _afficherMontants = true;
  bool _afficherQrCode = true;
  final List<ActiviteFacturable> _activites = [];

  @override
  void initState() {
    super.initState();
    _loadActivites();
  }

  Future<void> _loadActivites() async {
    final activites = await ActivitesFacturablesRepository()
        .getActivitesFacturables(
          widget.idDossier,
          dateDu: widget.dateDu,
          dateAu: widget.dateAu,
        );

    if (mounted) {
      setState(() {
        _activites.clear();
        _activites.addAll(activites);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options de génération de PDF'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Afficher la facture'),
            value: _afficherFacture,
            onChanged: (value) {
              setState(() => _afficherFacture = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('Facture: Afficher le QR code'),
            value: _afficherQrCode,
            onChanged: (value) {
              setState(() => _afficherQrCode = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('Afficher le relevé d\'activités'),
            value: _afficherReleveActivites,
            onChanged: (value) {
              setState(() => _afficherReleveActivites = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('Relevé: Afficher les frais'),
            value: _afficherFrais,
            onChanged: (value) {
              setState(() => _afficherFrais = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('Relevé: Afficher les montants'),
            value: _afficherMontants,
            onChanged: (value) {
              setState(() => _afficherMontants = value ?? true);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Générer PDF'),
          onPressed: () async {
            Navigator.of(context).pop();

            // Give the UI a short moment to finish closing the dialog.
            await Future.delayed(const Duration(milliseconds: 100));

            // Generate selected PDFs
            console.log('Début de la génération de la facture');

            late final dynamic pwFacture;
            if (_afficherFacture) {
              try {
                pwFacture = await FactureReport().generate(widget.idFacture);
              } catch (e, st) {
                console.log('Erreur lors de la génération de la facture: $e');
                console.log(st.toString());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur lors de la génération de la facture: $e',
                      ),
                    ),
                  );
                }
                return;
              }
            } else {
              pwFacture = null;
            }

            console.log('Début de la génération de la facture QR code');

            late final dynamic pwQrCode;
            if (_afficherQrCode) {
              try {
                final invoiceData = await FactureService().getInvoiceDataFromFacture(
                  widget.idFacture
                );
                pwQrCode = await generateQRBill(invoiceData, widget.montantFacture);
              } catch (e, st) {
                console.log('Erreur lors de la génération de la facture: $e');
                console.log(st.toString());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur lors de la génération de la facture QR code: $e',
                      ),
                    ),
                  );
                }
                return;
              }
            } else {
              pwQrCode = null;
            }

            console.log('Début de la génération du relevé d\'activités');

            final pwReleve = _afficherReleveActivites
                ? await ActivitesFacturablesReport().buildReleveActivitesPdf(
                    activites: _activites,
                    dateDu: widget.dateDu,
                    dateAu: widget.dateAu,
                    dossierLibelle: widget.dossierLibelle,
                    afficherFrais: _afficherFrais,
                    afficherMontants: _afficherMontants,
                  )
                : null;

            console.log(
              'Les documents PDF ont été générés. Facture: ${pwFacture != null}, Relevé: ${pwReleve != null}',
            );

            // If both present, merge using Syncfusion PdfDocument
            if (pwFacture != null && pwReleve != null) {
              final bytesA = await pwFacture.save();
              final bytesB = await pwReleve.save();
              final bytesC = pwQrCode;

              final docA = sf.PdfDocument(inputBytes: bytesA);
              final docB = sf.PdfDocument(inputBytes: bytesB);
              final docC = sf.PdfDocument(inputBytes: bytesC);

              final result = sf.PdfDocument();
              sf.PdfSection? section;

              console.log(
                'PDF fusionné généré : ${result.pages.count} pages avant fusion',
              );

              // Copy pages from first document using templates
              for (int i = 0; i < docA.pages.count; i++) {
                final sf.PdfTemplate template = docA.pages[0].createTemplate();
                if (section == null ||
                    section.pageSettings.size != template.size) {
                  section = result.sections!.add();
                  section.pageSettings.size = template.size;
                  section.pageSettings.margins.all = 0;
                }

                section.pages.add().graphics.drawPdfTemplate(
                  template,
                  const Offset(0, 0),
                );
              }

              // Copy pages from second document
              for (int i = 0; i < docB.pages.count; i++) {
                final sf.PdfTemplate template = docB.pages[i].createTemplate();
                if (section == null ||
                    section.pageSettings.size != template.size) {
                  section = result.sections!.add();
                  section.pageSettings.size = template.size;
                  section.pageSettings.margins.all = 0;
                }

                section.pages.add().graphics.drawPdfTemplate(
                  template,
                  const Offset(0, 0),
                );
              }
              // Copy pages from third document (QR code)
                final sf.PdfTemplate template = docC.pages[0].createTemplate();
                if (section == null ||
                    section.pageSettings.size != template.size) {
                  section = result.sections!.add();
                  section.pageSettings.size = template.size;
                  section.pageSettings.margins.all = 0;
                }

                section.pages[0].graphics.drawPdfTemplate(
                  template,
                  const Offset(0, 520),
                );
                //section.pages.add().graphics.drawPdfTemplate(
                //  template,
                //  const Offset(0, 0),
                //);

              final mergedBytes = await result.save();

              docA.dispose();
              docB.dispose();
              docC.dispose();
              result.dispose();

              final directory = await getApplicationDocumentsDirectory();
              final fileName =
                  'FA_${widget.idDossier.toString()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
              final file = File('${directory.path}/$fileName');
              await file.writeAsBytes(mergedBytes);
              await OpenFilex.open(file.path);
              mergedBytes.clear();
              console.log('PDF fusionné généré : ${file.path}');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF généré : ${file.path}')),
                );
              }

              return;
            }

            // If only one selected, save that one
            await Future.delayed(const Duration(milliseconds: 50));

            final singleDoc = pwFacture ?? pwReleve;
            if (singleDoc != null) {
              final pdfBytes = await singleDoc.save();
              final directory = await getApplicationDocumentsDirectory();
              final fileName =
                  '${_afficherFacture ? 'Facture' : 'Releve'}_${widget.dossierLibelle}_${DateTime.now().millisecondsSinceEpoch}.pdf';

              final file = File('${directory.path}/$fileName');
              await file.writeAsBytes(pdfBytes);

              // Ouverture automatique du PDF
              await OpenFilex.open(file.path);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF généré : ${file.path}')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

Future<Uint8List?> generateQRBill(InvoiceData invoiceData, double montantFacture) async {
  // Fonts must be loaded to display properly in test outputs
  final regularFont = File('assets/fonts/OpenSans-Regular.ttf')
      .readAsBytes()
      .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  final boldFont = File('assets/fonts/OpenSans-Bold.ttf').readAsBytes().then(
    (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
  );

  final fontLoader = FontLoader('OpenSans')
    ..addFont(regularFont)
    ..addFont(boldFont);
  await fontLoader.load();

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
