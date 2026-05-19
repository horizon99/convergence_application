import 'package:convergence_application/screens/facture_print_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repositories/facture_repository.dart';
import '../data/repositories/dossier_repository.dart';
import '../data/repositories/parties_repository.dart';
import '../models/facture_model.dart';
import '../models/dossier_model.dart';
import '../models/parties_model.dart';
import '../reports/facture_service.dart';
import 'facture_detail_screen.dart';

class FactureListScreen extends StatefulWidget {
  final int? dossierId;

  const FactureListScreen({super.key, this.dossierId});

  @override
  State<FactureListScreen> createState() => _FactureListScreenState();
}

class _FactureListScreenState extends State<FactureListScreen> {
  bool _loading = true;
  List<_FactureRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadRows();
  }

  Future<void> _loadRows() async {
    setState(() => _loading = true);
    final factures = widget.dossierId == null
        ? await FactureRepository().getAllFacturesAndPayments()
        : await FactureRepository().getFacturesAndPaymentsDossier(
            widget.dossierId!,
          );

    final List<_FactureRow> rows = [];

    for (final f in factures) {
      Dossier? dossier;
      String dossierLibelleClient = '';
      String clientNom = '';

      try {
        dossier = await DossierRepository().getDossierById(f.idDossier);
        dossierLibelleClient = dossier?.libelleClient ?? '';
      } catch (_) {}

      try {
        final parties = await PartiesRepository().getPartiesByDossier(
          f.idDossier,
        );
        final p = parties.firstWhere(
          (p) => p.contactId == f.idContact,
          orElse: () =>
              Parties(idPartie: 0, contactId: 0, dossierId: 0, nomPrenom: ''),
        );
        clientNom = p.nomPrenom;
      } catch (_) {}

      rows.add(
        _FactureRow(
          facture: f,
          dossierLibelle: dossierLibelleClient,
          clientNom: clientNom,
        ),
      );
    }

    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Factures')),
      body: RefreshIndicator(
        onRefresh: _loadRows,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: SizedBox.shrink()),
                  //DataColumn(label: Text('No Dossier')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Dossier/Client')),
                  DataColumn(label: Text('Activités')),
                  DataColumn(label: Text('Montant facturé')),
                  DataColumn(label: Text('Montant encaissé')),
                  DataColumn(label: Text('Solde restant')),
                  DataColumn(label: Text('Payé')),
                  DataColumn(label: SizedBox.shrink()),
                  //DataColumn(label: SizedBox.shrink()),
                ],
                rows: _rows.map((r) {
                  final f = r.facture;
                  return DataRow(
                    //color: (f.paye ? WidgetStateProperty.all(Colors.green[50]) : WidgetStateProperty.all(Colors.yellow[50])),
                    cells: [
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            size: 18,
                            color: Colors.red,
                          ),
                          tooltip: 'GénérerPDF',
                          onPressed: () async {
                            try {
                              final res = await showDialog<FacturePrintResult?>(
                                context: context,
                                builder: (context) => FacturePrintDialog(),
                              );

                              if (res != null && res.generated) {
                                await FactureService().generateFacturePDF(
                                  {},
                                  idFacture: f.idFacture,
                                  afficherFacture: res.afficherFacture,
                                  afficherQrCode: res.afficherQrCode,
                                  afficherReleveActivites:
                                      res.afficherReleveActivites,
                                  afficherFrais: res.afficherFrais,
                                  afficherMontants: res.afficherMontants,
                                  montantFacture: f.montantFacture,
                                  idDossier: f.idDossier,
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Echec generation PDF: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      //DataCell(Text(f.idDossier.toString())
                      DataCell(Text(DateFormat('dd.MM.yyyy').format(f.dateOp))),
                      DataCell(
                        Text(
                          '${f.idDossier} - ${r.clientNom.isNotEmpty ? r.clientNom : f.idContact.toString()}',
                        ),
                      ),
                      DataCell(
                        Text(
                          '${_fmtDate(f.activitesDu)} - ${_fmtDate(f.activitesAu)}',
                        ),
                      ),
                      DataCell(Text('CHF ${_fmtDouble(f.montantFacture)}')),
                      DataCell(Text('CHF ${_fmtDouble(f.montantEncaisse)}')),
                      DataCell(Text('CHF ${_fmtDouble(f.soldeRestant)}')),
                      DataCell(
                        Text(
                          f.paye == true ? 'Oui' : 'Non',
                          style: TextStyle(
                            color: f.paye == true
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Éditer la facture',
                              onPressed: () async {
                                final fact = await FactureRepository()
                                    .getFactureById(f.idFacture);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FacturePrepare(
                                      dossierId: f.idDossier,
                                      dateDu: f.activitesDu ?? f.dateOp,
                                      dateAu: f.activitesAu ?? f.dateOp,
                                      facture: fact,
                                    ),
                                  ),
                                );
                                await _loadRows();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              tooltip: 'Supprimer la facture',
                              onPressed: () => _confirmDelete(f),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelectChanged: (_) {},
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(FacturePaiement f) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la facture'),
        content: const Text(
          'Es-tu sûr de vouloir supprimer cette facture ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FactureRepository().deleteFacture(f.idFacture);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Facture supprimée')));
      await _loadRows();
    }
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd.MM.yyyy').format(d);
  }

  static String _fmtDouble(num? v) {
    if (v == null) return '0.00';
    return v.toDouble().toStringAsFixed(2);
  }
}

class _FactureRow {
  final FacturePaiement facture;
  final String dossierLibelle;
  final String clientNom;

  _FactureRow({
    required this.facture,
    required this.dossierLibelle,
    required this.clientNom,
  });
}
