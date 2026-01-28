import 'dart:io';
import 'package:convergence_application/reports/facture_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FactureReport {
  Future<void> generate(
      int dossierId, DateTime dateDu, DateTime dateAu) async {
    final invoiceData =
        await FactureService().getInvoiceData(dossierId, dateDu, dateAu);

    final pdf = pw.Document();

    final Uint8List? logoData = invoiceData.mediateur.logo;
    final pw.ImageProvider? logoImage =
        logoData != null ? pw.MemoryImage(logoData) : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) =>
            _buildHeader(invoiceData, logoImage),
        build: (context) => [
          _buildTitle(invoiceData, dateDu, dateAu),
          _buildInvoice(invoiceData),
          _buildTotal(invoiceData),
        ],
        footer: (context) => _buildFooter(invoiceData),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/facture.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFilex.open(file.path);
  }

  pw.Widget _buildHeader(InvoiceData data, pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(data.mediateur.nom ?? '',
                style: 
                pw.TextStyle(fontSize: 16,
                    fontWeight: pw.FontWeight.bold
                    ),
            ),
            pw.Text(data.mediateur.factureAdresse ?? ''),
            pw.Text(
                '${data.mediateur.factureNoPostal} ${data.mediateur.factureLocalite}'),
            pw.Text(data.mediateur.telephone ?? ''),
            pw.Text(data.mediateur.email ?? ''),
          ],
        ),
        if (logo != null) pw.Image(logo, width: 150),
      ],
    );
  }

  pw.Widget _buildTitle(InvoiceData data, DateTime dateDu, DateTime dateAu) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 2 * PdfPageFormat.cm),
        pw.Text(
            '${data.client.titre} ${data.client.prenom} ${data.client.nom}'),
        pw.Text(data.client.adresse ?? ''),
        pw.Text('${data.client.noPostal} ${data.client.localite}'),
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
        pw.Text('Facture pour la période du ${DateFormat('dd.MM.yyyy').format(dateDu)} au ${DateFormat('dd.MM.yyyy').format(dateAu)}',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Dossier: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: data.dossier.libelle),
            ],
          ),
        ),
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
      ],
    );
  }

  pw.Widget _buildInvoice(InvoiceData data) {
    final headers = ['Description', 'Minutes', 'Tarif/h', 'Total'];

    final tableData = data.content.map((item) {
      final double facturable = (item.totalHonoraires ?? 0) + (item.totalFrais ?? 0);
      return [
        item.descriptionTarif,
        item.totalMinutes,
        NumberFormat.currency(symbol: 'CHF').format(item.montantTarif),
        NumberFormat.currency(symbol: 'CHF')
            .format(facturable),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: tableData,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerRight,
      cellAlignments: {0: pw.Alignment.centerLeft},
      border: pw.TableBorder.all(),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
    );
  }

  pw.Widget _buildTotal(InvoiceData data) {
    final double subTotal = data.content
        .fold(0, (sum, item) => sum + (item.totalHonoraires ?? 0) + (item.totalFrais ?? 0));
    final double tva = subTotal * (data.dossier.tva ?? 0) / 100;
    final double total = subTotal + tva;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Sous-total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(NumberFormat.currency(symbol: 'CHF').format(subTotal)),
            ],
          ),
          if (data.dossier.tva != null && data.dossier.tva! > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('TVA (${data.dossier.tva}%): ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(NumberFormat.currency(symbol: 'CHF').format(tva)),
              ],
            ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text(NumberFormat.currency(symbol: 'CHF').format(total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Text('Merci de votre confiance.'),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Text('IBAN: ${data.mediateur.iban ?? ''}'),
      ],
    );
  }
}
