import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repositories/facture_repository.dart';
import '../data/repositories/dossier_repository.dart';
import '../data/repositories/parties_repository.dart';
import '../models/facture_model.dart';
import '../models/dossier_model.dart';
import '../models/parties_model.dart';

class FactureListScreen extends StatefulWidget {
  const FactureListScreen({super.key});

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
    final factures = await FactureRepository().getAllFactures();
    final List<_FactureRow> rows = [];

    for (final f in factures) {
      Dossier? dossier;
      String dossierLibelle = '';
      String clientNom = '';

      try {
        dossier = await DossierRepository().getDossierById(f.dossierID);
        dossierLibelle = dossier?.libelle ?? '';
      } catch (_) {}

      try {
        final parties = await PartiesRepository().getPartiesByDossier(f.dossierID);
        final p = parties.firstWhere((p) => p.contactId == f.contactID, orElse: () => Parties(idPartie: 0, contactId: 0, dossierId: 0, nomPrenom: ''));
        clientNom = p.nomPrenom;
      } catch (_) {}

      rows.add(_FactureRow(
        facture: f,
        dossierLibelle: dossierLibelle,
        clientNom: clientNom,
      ));
    }

    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                  DataColumn(label: Text('Dossier')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Activités')),
                  DataColumn(label: Text('Montant total')),
                  DataColumn(label: Text('Montant facturé')),
                ],
                rows: _rows.map((r) {
                  final f = r.facture;
                  return DataRow(
                    cells: [
                      DataCell(Text(r.dossierLibelle.isNotEmpty ? r.dossierLibelle : 'Dossier ${f.dossierID}')),
                      DataCell(Text(DateFormat('dd.MM.yyyy').format(f.dateOp))),
                      DataCell(Text(r.clientNom.isNotEmpty ? r.clientNom : f.contactID.toString())),
                      DataCell(Text('${_fmtDate(f.activitesDu)} - ${_fmtDate(f.activiteAu)}')),
                      DataCell(Text('CHF ${_fmtDouble(f.montant)}')),
                      DataCell(Text('CHF ${_fmtDouble(f.facturable)}')),
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
  final Facture facture;
  final String dossierLibelle;
  final String clientNom;

  _FactureRow({required this.facture, required this.dossierLibelle, required this.clientNom});
}
