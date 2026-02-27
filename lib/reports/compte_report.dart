import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/ecriture_model.dart';

class CompteReport extends StatelessWidget {
  final List<Ecriture> items;
  final Map<int, String> compteLabels;
  final String accountName;

  const CompteReport({
    super.key,
    required this.items,
    required this.compteLabels,
    required this.accountName,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final double totalRecettes =
        items.where((e) => e.nature == 'recette').fold(0.0, (s, e) => s + e.montant);
    final double totalDepenses =
        items.where((e) => e.nature == 'depense').fold(0.0, (s, e) => s + e.montant);
    final double netTotal = totalRecettes - totalDepenses;

    // sort items by date ascending for display
    final sortedItems = List<Ecriture>.from(items)
      ..sort((a, b) => a.date.compareTo(b.date));

    // detect whether one of the compte columns is constant across all items
    final bool allSameAP = sortedItems.isNotEmpty && sortedItems.every((e) => e.compteActifPassifId == sortedItems[0].compteActifPassifId);
    final bool allSameCP = sortedItems.isNotEmpty && sortedItems.every((e) => e.compteChargeProduitId == sortedItems[0].compteChargeProduitId);
    final bool useSingleCompteColumn = allSameAP || allSameCP;
    final bool selectedIsAP = allSameAP;

    return Scaffold(
      appBar: AppBar(
        title: Text('Relevé des écritures: $accountName'),
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: useSingleCompteColumn
                    ? [
                        const DataColumn(label: Text('Date')),
                        DataColumn(label: Text(selectedIsAP ? 'Compte A/P' : 'Compte C/P')),
                        const DataColumn(label: Text('Libellé')),
                        const DataColumn(label: Text('Recette')),
                        const DataColumn(label: Text('Dépense')),
                      ]
                    : const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Compte A/P')),
                        DataColumn(label: Text('Compte C/P')),
                        DataColumn(label: Text('Libellé')),
                        DataColumn(label: Text('Recette')),
                        DataColumn(label: Text('Dépense')),
                      ],
                rows: sortedItems.map((e) {
                  if (useSingleCompteColumn) {
                    final int id = selectedIsAP ? e.compteActifPassifId : e.compteChargeProduitId;
                    return DataRow(cells: [
                      DataCell(Text(_formatDate(e.date))),
                      DataCell(Text(compteLabels[id] ?? id.toString())),
                      DataCell(Text(e.description ?? '')),
                      DataCell(Text(e.nature == 'recette' ? e.montant.toStringAsFixed(2) : '')),
                      DataCell(Text(e.nature == 'depense' ? e.montant.toStringAsFixed(2) : '')),
                    ]);
                  } else {
                    return DataRow(cells: [
                      DataCell(Text(_formatDate(e.date))),
                      DataCell(Text(compteLabels[e.compteActifPassifId] ?? e.compteActifPassifId.toString())),
                      DataCell(Text(compteLabels[e.compteChargeProduitId] ?? e.compteChargeProduitId.toString())),
                      DataCell(Text(e.description ?? '')),
                      DataCell(Text(e.nature == 'recette' ? e.montant.toStringAsFixed(2) : '')),
                      DataCell(Text(e.nature == 'depense' ? e.montant.toStringAsFixed(2) : '')),
                    ]);
                  }
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Total recettes: ${totalRecettes.toStringAsFixed(2)}'),
                  Text('Total dépenses: ${totalDepenses.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Solde du compte: ${netTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: netTotal >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Build a PDF document for the compte report and return bytes
Future<Uint8List> buildCompteReportPdf(List<Ecriture> items, Map<int, String> compteLabels, String accountName) async {
  final doc = pw.Document();

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
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) => [
        pw.Header(level: 0, child: pw.Text('Relevé des écritures: $accountName')),
        pw.SizedBox(height: 8),
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
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'recette' ? e.montant.toStringAsFixed(2) : '', style: const pw.TextStyle(fontSize: 9)))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'depense' ? e.montant.toStringAsFixed(2) : '', style: const pw.TextStyle(fontSize: 9)))),
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
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'recette' ? e.montant.toStringAsFixed(2) : '', style: const pw.TextStyle(fontSize: 9)))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(e.nature == 'depense' ? e.montant.toStringAsFixed(2) : '', style: const pw.TextStyle(fontSize: 9)))),
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
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(totalRecettes.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(totalDepenses.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                    ]
                  : [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Totaux', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(totalRecettes.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(totalDepenses.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
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
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(netTotal.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
                    ]
                  : [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Solde du compte', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(netTotal.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)))),
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
