import '../../reports/facture_service.dart';
import '../app_helper.dart';
import '../data/repositories/facture_repository.dart';
import '../models/facture_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FactureReport {
  Future<pw.Document> generate(int idFacture) async {
    final invoiceData = await FactureService().getInvoiceDataFromFacture(
      idFacture,
    );
    final factureRecord = await FactureRepository().getFactureById(idFacture);

    final pdf = pw.Document();

    final Uint8List? logoData = invoiceData.mediateur.logo;
    final pw.ImageProvider? logoImage = logoData != null
        ? pw.MemoryImage(logoData)
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildTitle(invoiceData, factureRecord!),
          _buildInvoice(invoiceData, factureRecord),
          _buildTotal(invoiceData, factureRecord),
        ],
        header: (context) => _buildHeader(invoiceData, logoImage),
        footer: (context) => _buildFooter(invoiceData, factureRecord!),
      ),
    );

    //final output = await getTemporaryDirectory();
    //final file = File(
    //  '${output.path}/FA_${invoiceData.client.nomPrenom}_${idFacture.toString()}.pdf',
    //);
    //await file.writeAsBytes(await pdf.save());

    //OpenFilex.open(file.path);
    return pdf;
  }

  pw.Widget _buildHeader(InvoiceData data, pw.ImageProvider? logo) {
    // TODO: remettre un SizedBox pour le logo et le bloc d'en-tête.
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.mediateur.nom ?? '',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                data.mediateur.factureAdresse ?? '',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                '${data.mediateur.factureNoPostal} ${data.mediateur.factureLocalite}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                data.mediateur.telephone ?? '',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                data.mediateur.email ?? '',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        if (logo != null)
          pw.SizedBox(
            width: data.mediateur.logoW?.toDouble() ?? 150,
            height: data.mediateur.logoH?.toDouble() ?? 75,
            child: pw.Image(
              logo,
              fit: pw.BoxFit.contain,
            ),
          ),
      ],
    );
  }

  pw.Widget _buildTitle(InvoiceData data, Facture factureRecord) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 2 * PdfPageFormat.cm),

        // Client address block shifted 9 cm to the right
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: 9 * PdfPageFormat.cm,
            top: -2 * PdfPageFormat.cm,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.client.titre != null && data.client.titre!.isNotEmpty)
                pw.Text(
                  '${data.client.titre}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              pw.Text(
                '${data.client.prenom} ${data.client.nom}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '${data.client.adresse} ${data.client.noRue}',
                style: pw.TextStyle(fontSize: 12),
              ),
              if (data.client.adresse2 != null &&
                  data.client.adresse2!.isNotEmpty)
                pw.Text(
                  data.client.adresse2!,
                  style: pw.TextStyle(fontSize: 12),
                ),
              pw.Text(
                '${data.client.noPostal} ${data.client.localite}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 1.5 * PdfPageFormat.cm),
              pw.Text(
                '${data.mediateur.localite} ${DateFormat('d MMMM yyyy', 'fr').format(factureRecord.dateOp)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),

        pw.Text(
          factureRecord.titre ?? 'Facture',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),

        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Concerne: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              pw.TextSpan(text: data.dossier.libelleClient),
            ],
          ),
        ),

        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),

        if (factureRecord.libelle != null && factureRecord.libelle!.isNotEmpty)
          pw.Text(
            factureRecord.libelle!,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
          ),

        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),

        pw.Text(
          'Période du ${data.dateDu != null ? DateFormat('dd.MM.yyyy').format(data.dateDu!) : '-'} au ${data.dateAu != null ? DateFormat('dd.MM.yyyy').format(data.dateAu!) : '-'}',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.normal,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoice(InvoiceData data, Facture factureRecord) {
    final headers = ['Description', 'Heures', 'Tarif/h', 'Frais', 'Total'];

    final tableData = data.content.map((item) {
      final double facturable =
          (item.totalHonoraires ?? 0) + (item.totalFrais ?? 0);
      return [
        item.texteFacture ?? '',
        AppHelper.minutesToHours(item.totalMinutes ?? 0),
        NumberFormat.currency(symbol: 'CHF ').format(item.montantTarif),
        NumberFormat.currency(symbol: 'CHF ').format(item.totalFrais),
        NumberFormat.currency(symbol: 'CHF ').format(facturable),
      ];
    }).toList();

    final footers = [
      'Total',
      '',
      '',
      NumberFormat.currency(symbol: 'CHF ').format(factureRecord.frais),
      NumberFormat.currency(symbol: 'CHF ').format(factureRecord.honoraires),
    ];

    // Fixed column widths: Description (large), Minutes, Tarif/h, Total
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(5),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(3),
      3: const pw.FlexColumnWidth(3),
      4: const pw.FlexColumnWidth(3),
    };

    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    );

    final headerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: headers
          .map(
            (h) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(h, style: headerStyle),
            ),
          )
          .toList(),
    );

    final footerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      children: footers
          .map(
            (h) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                h,
                style: headerStyle,
                textAlign: pw.TextAlign.right,
              ),
            ),
          )
          .toList(),
    );

    final dataRows = tableData.map((row) {
      return pw.TableRow(
        children: row.asMap().entries.map((entry) {
          final idx = entry.key;
          final cell = entry.value;
          final align = idx == 0
              ? pw.Alignment.centerLeft
              : pw.Alignment.centerRight;
          return pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Align(
              alignment: align,
              child: pw.Text(
                cell.toString(),
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          );
        }).toList(),
      );
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: columnWidths,
      children: [headerRow, ...dataRows, footerRow],
    );
  }

  pw.Widget _buildTotal(InvoiceData data, Facture factureRecord) {
    //final double totalHonoraires = data.content.fold(0, (sum, item) => sum + (item.totalHonoraires ?? 0) );
    //final double totalFrais = data.content.fold(0, (sum, item) => sum + (item.totalFrais ?? 0) );
    //final double subTotal = data.content
    //.fold(0, (sum, item) => sum + (item.totalHonoraires ?? 0) + (item.totalFrais ?? 0));
    //final double tva = subTotal * (data.dossier.tva ?? 0) / 100;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          // if (data.dossier.tva != null && data.dossier.tva! > 0) le jour on met la tva
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total honoraires et frais: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                NumberFormat.currency(
                  symbol: 'CHF ',
                ).format(factureRecord.total),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (factureRecord.tauxParticipation! > 0)
            pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Part ${factureRecord.tauxParticipation}% à votre charge: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                NumberFormat.currency(
                  symbol: 'CHF ',
                ).format(factureRecord.participation),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(InvoiceData data, Facture factureRecord) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Text(
          factureRecord.conditions ??
              'Facture payable net à 30 jours, avec mes remerciements.',
        ),
        //pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        //pw.Text('IBAN: ${data.mediateur.iban ?? ''}'),
      ],
    );
  }
}