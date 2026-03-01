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

  @override

// Build a PDF document for the compte report and return bytes
Future<Uint8List> buildCompteReportPdf(List<Ecriture> items, Map<int, String> compteLabels, String accountName) async {
  final doc = pw.Document();
  final Mediateur mediateur = await MediateurRepository().getMediateur();

  // Load OpenSans fonts from assets and register them with the PDF theme
  final ByteData regularData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
  final ByteData boldData = await rootBundle.load('assets/fonts/OpenSans-Bold.ttf');
  final pw.Font fontRegular = pw.Font.ttf(regularData.buffer.asByteData());
  final pw.Font fontBold = pw.Font.ttf(boldData.buffer.asByteData());

  final NumberFormat montantFormat = NumberFormat("#,##0.00", 'de_CH');

  // sort items by date ascending for PDF
  final sorted = List<Ecriture>.from(items)..sort((a, b) => a.date.compareTo(b.date));

  final totalRecettes = sorted.where((e) => e.nature == 'recette').fold(0.0, (s, e) => s + e.montant);
  final totalDepenses = sorted.where((e) => e.nature == 'depense').fold(0.0, (s, e) => s + e.montant);
  final netTotal = totalRecettes - totalDepenses;

  // detect whether one of the compte columns is constant across all items (PDF)
  final bool allSameAPPdf = sorted.isNotEmpty && sorted.every((e) => e.compteActifPassifId == sorted[0].compteActifPassifId);
  final bool allSameCPPdf = sorted.isNotEmpty && sorted.every((e) => e.compteChargeProduitId == sorted[0].compteChargeProduitId);
  final bool useSingleCompteColumnPdf = allSameAPPdf || allSameCPPdf;
  final bool selectedIsAPPdf = allSameCPPdf;

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
                  'Exercice ${sorted.isNotEmpty ? sorted[0].date.year : DateTime.now().year}',
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
          child: 
          pw.Row(
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
          
          

      build: (pw.Context ctx) => [
        pw. SizedBox(height: 8),
        pw.Header(level: 0, child: pw.Text('Relevé des écritures: $accountName')),
        //pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder(),
          defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            // header
            pw.TableRow(
              decoration: const pw.BoxDecoration(),
              children: useSingleCompteColumnPdf
                  ? [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(selectedIsAPPdf ? 'Compte A/P' : 'Compte C/P', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
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
            // data rows (sorted by date asc)
            ...sorted.map((e) {
              if (useSingleCompteColumnPdf) {
                final int id = selectedIsAPPdf ? e.compteActifPassifId : e.compteChargeProduitId;
                return pw.TableRow(
                  decoration: const pw.BoxDecoration(),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}', style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(compteLabels[id] ?? id.toString(), style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.description ?? '', style: const pw.TextStyle(fontSize: 9))),
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
              children: useSingleCompteColumnPdf
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
              children: useSingleCompteColumnPdf
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
      ],
    ),
  );

  try {
    return doc.save();
  } catch (e, st) {
    // Log and rethrow with stacktrace to help debugging when exceptions
    // occur inside the PDF generation (which may use isolates internally).
    // ignore: avoid_print
    print('Exception in buildCompteReportPdf: $e\n$st');
    throw Exception('Erreur lors de la construction du PDF: $e\n$st');
  }
}

// Helper: build the PDF, save to temporary file and open it
Future<void> exportCompteReportPdfToFile(List<Ecriture> items, Map<int, String> compteLabels, String accountName, {String? fileName}) async {
  try {
    final bytes = await buildCompteReportPdf(items, compteLabels, accountName);
    await Future.delayed(const Duration(milliseconds: 100));
    final dir = await getTemporaryDirectory();
    final name = fileName ?? 'compte_releve_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await Future.delayed(const Duration(milliseconds: 100));
    OpenFilex.open(file.path);
  } catch (e, st) {
    // ignore: avoid_print
    print('Exception in exportCompteReportPdfToFile: $e\n$st');
    rethrow;
  }
}
