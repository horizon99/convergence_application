import 'package:convergence_application/app_helper.dart';
import 'package:convergence_application/data/repositories/mediateur_repository.dart';
import 'package:convergence_application/models/mediateur_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:convergence_application/models/activites_facturables_model.dart';

class ActivitesFacturablesReport {
  Future<pw.Document> buildReleveActivitesPdf({
    required List<ActiviteFacturable> activites,
    required DateTime dateDu,
    required DateTime dateAu,
    required String dossierLibelle,
    required bool afficherFrais,
    required bool afficherMontants,
  }) async {
    final pdf = pw.Document();
    final dateFmt = DateFormat('dd.MM.yyyy');
    final Mediateur mediateur = await MediateurRepository().getMediateur();

    /// ─────────────────────────────
    /// Regroupement par tarif
    /// ─────────────────────────────
    final Map<String, List<ActiviteFacturable>> groupes = {};

    for (final a in activites) {
      final code = a.activite.codeTarif.isNotEmpty
          ? a.activite.codeTarif
          : '-';
      groupes.putIfAbsent(code, () => []).add(a);
    }

    /// Ordre des groupes selon groupeTarif
    final groupesTries = groupes.entries.toList()
      ..sort(
        (a, b) => (a.value.first.ordreTarif ?? 0).compareTo(
          b.value.first.ordreTarif ?? 0,
        ),
      );

    /// Totaux généraux
    double totalMinutes = 0;
    double totalFrais = 0;
    double totalMontant = 0;
    double totalHonoraires = 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  dossierLibelle,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                mediateur.nom ?? 'Cabinet de médiation',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        build: (context) => [
          /// ───────────── EN-TÊTE
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            //mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  //crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Relevé des activités',
                      style: const pw.TextStyle(fontSize: 16),
                      textAlign: pw.TextAlign.left,
                    ),
                    pw.Text(
                      'Du ${dateFmt.format(dateDu)} au ${dateFmt.format(dateAu)}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontStyle: pw.FontStyle.italic,
                      ),
                      textAlign: pw.TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.Divider(),

          /// ───────────── GROUPES
          ...groupesTries.expand((groupe) {
            final activites = groupe.value
              ..sort((a, b) => a.activite.dateActivite.compareTo(b.activite.dateActivite));

            final tarifHoraire = activites.first.tarifHoraire;
            final descriptionTarif = activites.first.descriptionTarif;

            double totalMinutesGroupe = 0;
            double totalFraisGroupe = 0;
            double totalHonorairesGroupe = 0;

            for (final a in activites) {
              totalMinutesGroupe += a.activite.minutes ?? 0;
              totalFraisGroupe += a.activite.frais ?? 0;
              totalHonorairesGroupe +=
                  ((a.activite.minutes ?? 0) * (a.tarifHoraire / 60));
            }

            totalMinutes += totalMinutesGroupe;
            totalFrais += totalFraisGroupe;
            totalHonoraires += totalHonorairesGroupe;
            totalMontant += activites.fold(
              0,
              (sum, a) => sum + a.montantFacturable,
            );

            return [
              /// En-tête de groupe
              pw.SizedBox(height: 16),
              pw.Text(
                descriptionTarif,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 6),

              /// Tableau des activités
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(width: 0.5),
                  top: pw.BorderSide(width: 0.8),
                  bottom: pw.BorderSide(width: 0.8),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(6),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _th('Date'),
                      _th('Libellé'),
                      if (afficherFrais)
                        _th('Frais', align: pw.TextAlign.right),
                      _th('Minutes', align: pw.TextAlign.right),
                    ],
                  ),
                  ...activites.map(
                    (a) => pw.TableRow(
                      children: [
                        _td(dateFmt.format(a.activite.dateActivite)),
                        _td(a.activite.libelle),
                        if (afficherFrais)
                          _td(
                            a.activite.frais?.toStringAsFixed(2) ?? '',
                            align: pw.TextAlign.right,
                          ),
                        _td(
                          a.activite.minutes?.toStringAsFixed(0) ?? '',
                          align: pw.TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// Pied de groupe
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    if (afficherMontants)
                      pw.Text(
                        '(${totalMinutesGroupe.toStringAsFixed(0)} minutes à CHF ${tarifHoraire.toStringAsFixed(2)}/h)',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.SizedBox(width: 10),
                    if (afficherFrais)
                      pw.Container(
                        width: 70,
                        child: pw.Text(
                          'CHF ${totalFraisGroupe.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    pw.SizedBox(width: 10),
                    if (afficherMontants)
                      pw.Container(
                        width: 70,
                        child: pw.Text(
                          'CHF ${totalHonorairesGroupe.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ];
          }),

          pw.Divider(),

          /// ───────────── PIED D’ÉTAT
          ///
          pw.Text(
            'Récapitulatif',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 6),

          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(8),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  _tr('Temps'),
                  _tr('Heures'),
                  _tr(
                    AppHelper.minutesToHours(totalMinutes.toInt()),
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
              if (afficherFrais)
                pw.TableRow(
                  children: [
                    _tr('Frais'),
                    _tr('CHF'),
                    _tr(
                      totalFrais.toStringAsFixed(2),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              if (afficherMontants)
                pw.TableRow(
                  children: [
                    _tr('Honoraires'),
                    _tr('CHF'),
                    _tr(
                      totalHonoraires.toStringAsFixed(2),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              if (afficherMontants & afficherFrais)
                pw.TableRow(
                  children: [
                    _tr('Montant honoraires et frais'),
                    _tr('CHF'),
                    _tr(
                      totalMontant.toStringAsFixed(2),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _th(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _tr(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
      ),
    );
  }
}
