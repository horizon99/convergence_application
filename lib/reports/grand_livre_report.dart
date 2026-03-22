import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/repositories/mediateur_repository.dart';
import '../models/ecriture_model.dart';
import '../models/mediateur_model.dart';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

// Build a PDF document for the compte report and return bytes
Future<Uint8List> buildGrandLivreReportPdf(List<Ecriture> items, Map<int, String> compteLabels, Map<int, String> compteNumeros) async {
  final doc = pw.Document();
  final Mediateur mediateur = await MediateurRepository().getMediateur();

  // Load OpenSans fonts from assets and register them with the PDF theme
  final ByteData regularData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
  final ByteData boldData = await rootBundle.load('assets/fonts/OpenSans-Bold.ttf');
  final pw.Font fontRegular = pw.Font.ttf(regularData.buffer.asByteData());
  final pw.Font fontBold = pw.Font.ttf(boldData.buffer.asByteData());

  final NumberFormat montantFormat = NumberFormat("#,##0.00", 'de_CH');

    // global sort for header year
  final globalSorted = List<Ecriture>.from(items)..sort((a, b) => a.date.compareTo(b.date));

  // collect distinct account ids from both compte columns
  final Set<int> accountIds = {};
  for (final e in items) {
    accountIds.add(e.compteActifPassifId);
    accountIds.add(e.compteChargeProduitId);
  }

  // build a section per account id
  final List<pw.Widget> content = [];
  content.add(pw.SizedBox(height: 8));
  for (final accountId in accountIds.toList()..sort()) {
    final accountEntries = items.where((e) => e.compteActifPassifId == accountId || e.compteChargeProduitId == accountId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (accountEntries.isEmpty) continue;

    final totalRecettes = accountEntries.where((e) => e.nature == 'recette').fold(0.0, (s, e) => s + e.montant);
    final totalDepenses = accountEntries.where((e) => e.nature == 'depense').fold(0.0, (s, e) => s + e.montant);
    final netTotal = totalRecettes - totalDepenses;

    // detect whether one of the compte columns is constant across these entries
    final bool allSameAP = accountEntries.isNotEmpty && accountEntries.every((e) => e.compteActifPassifId == accountEntries[0].compteActifPassifId);
    final bool allSameCP = accountEntries.isNotEmpty && accountEntries.every((e) => e.compteChargeProduitId == accountEntries[0].compteChargeProduitId);
    final bool useSingleCompte = allSameAP || allSameCP;
    final bool selectedIsAP = allSameCP;

    content.add(pw.Header(level: 1, child: pw.Text('${compteNumeros[accountId] ?? accountId.toString()} - ${compteLabels[accountId] ?? accountId.toString()}')));
    content.add(
      pw.Table(
        border: pw.TableBorder(),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // header
          pw.TableRow(
            decoration: const pw.BoxDecoration(),
            children: useSingleCompte
                ? [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(selectedIsAP ? 'Compte A/P' : 'Compte C/P', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Libellé', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Recette', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Dépense', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ]
                : [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Compte A/P', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Compte C/P', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Libellé', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Recette', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Dépense', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
          ),

          // data rows
          ...accountEntries.map((e) {
            if (useSingleCompte) {
              final int id = selectedIsAP ? e.compteActifPassifId : e.compteChargeProduitId;
              return pw.TableRow(
                decoration: const pw.BoxDecoration(),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(compteLabels[id] ?? id.toString(), style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.description ?? '', style: const pw.TextStyle(fontSize: 9)) ),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'recette' ? montantFormat.format(e.montant) : '', style: const pw.TextStyle(fontSize: 9)))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'depense' ? montantFormat.format(e.montant) : '', style: const pw.TextStyle(fontSize: 9)))),
                ],
              );
            } else {
              return pw.TableRow(
                decoration: const pw.BoxDecoration(),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(compteLabels[e.compteActifPassifId] ?? e.compteActifPassifId.toString(), style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(compteLabels[e.compteChargeProduitId] ?? e.compteChargeProduitId.toString(), style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.description ?? '', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'recette' ? montantFormat.format(e.montant) : '', style: const pw.TextStyle(fontSize: 9)))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'depense' ? montantFormat.format(e.montant) : '', style: const pw.TextStyle(fontSize: 9)))),
                ],
              );
            }
          }),

          // totals row
          pw.TableRow(
            decoration: const pw.BoxDecoration(),
            children: useSingleCompte
                ? [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Totaux', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(totalRecettes), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(totalDepenses), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                  ]
                : [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Totaux', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(totalRecettes), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(totalDepenses), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                  ],
          ),
          pw.TableRow(
            decoration: const pw.BoxDecoration(),
            children: useSingleCompte
                ? [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Solde du compte', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(netTotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                  ]
                : [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Solde du compte', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(montantFormat.format(netTotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                  ],
          ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
      pageFormat: PdfPageFormat.a4,
      header: (context) => pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Grand livre ${globalSorted.isNotEmpty ? globalSorted[0].date.year : DateTime.now().year}',
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
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                _formatDate(DateTime.now()),
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
      build: (pw.Context ctx) => content,
    ),
  );
  return await doc.save();
}

// Helper: build the PDF, save to temporary file and open it
Future<void> exportGrandLivreReportPdfToFile(List<Ecriture> items, Map<int, String> compteLabels, Map<int, String> compteNumeros, {String? fileName}) async {
  try {
    final bytes = await buildGrandLivreReportPdf(items, compteLabels, compteNumeros);
    await Future.delayed(const Duration(milliseconds: 100));
    final dir = await getTemporaryDirectory();
    final name = fileName ?? 'grand_livre_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await Future.delayed(const Duration(milliseconds: 100));
    OpenFilex.open(file.path);
  } catch (e, st) {
    // ignore: avoid_print
    print('Exception in exportGrandLivreReportPdfToFile: $e\n$st');
    rethrow;
  }
}
