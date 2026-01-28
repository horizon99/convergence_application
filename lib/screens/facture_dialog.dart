import 'facture_contenu_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/facture_contenu_model.dart';
import '../models/parties_model.dart';
import '../data/repositories/parties_repository.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../data/repositories/facture_repository.dart';
import '../app_helper.dart';

class FacturePrepare extends StatefulWidget {
  final int dossierId;
  final DateTime dateDu;
  final DateTime dateAu;
  const FacturePrepare({
    super.key,
    required this.dossierId,
    required this.dateDu,
    required this.dateAu,
  });

  @override
  State<FacturePrepare> createState() => _FacturePrepareState();
}

class _FacturePrepareState extends State<FacturePrepare> {
  DateTime _dateOp = DateTime.now();
  int? _selectedClientId;
  double _participation = 1.0;
  String _titre = 'FACTURE';
  String _libelle = 'Je me permets de vous facturer mes honoraires comme suit:';
  String _conditions =
      'Facture payable net à 30 jours, avec mes remerciements.';
  List<Parties> _clients = [];
  List<FactureContenu> _contenu = [];
  double _totalHonoraires = 0.0;
  double _totalFrais = 0.0;
  double _grandTotal = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients = await PartiesRepository().getPartiesByDossier(
      widget.dossierId,
    );
    final contenu = await ActivitesFacturablesRepository()
        .getMontantsFacturables(
          widget.dossierId,
          dateDu: widget.dateDu,
          dateAu: widget.dateAu,
        );
    setState(() {
      _clients = clients.where((p) => p.role == 'Client').toList();
      _contenu = contenu;
      _calculateTotals();
      _loading = false;
    });
  }

  void _calculateTotals() {
    _totalHonoraires = _contenu.fold(
      0.0,
      (sum, c) => sum + (c.totalHonoraires ?? 0),
    );
    _totalFrais = _contenu.fold(0.0, (sum, c) => sum + (c.totalFrais ?? 0));
    _grandTotal = (_totalHonoraires + _totalFrais) * _participation;
  }

  Future<void> _onClientChanged(int? clientId) async {
    if (clientId == null) return;
    final partie = _clients.firstWhere((p) => p.contactId == clientId);
    setState(() {
      _selectedClientId = clientId;
      _participation = (partie.facturable ?? 100) / 100.0;
      _calculateTotals();
    });
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  // Optionally implement editing of FactureContenu if needed

  Future<void> _onOk() async {
    if (_selectedClientId == null) return;
    final facture = Facture(
      idFacture: 0, // Will be set by DB
      dateOp: _dateOp,
      dossierID: widget.dossierId,
      contactID: _selectedClientId!,
      titre: _titre,
      libelle: _libelle,
      conditions: _conditions,
      contenu: _serializeContenu(_contenu),
      facturable: _totalHonoraires,
      montant: _grandTotal,
      participation: _participation,
      activitesDu: widget.dateDu,
      activiteAu: widget.dateAu,
    );
    await FactureRepository().insertFacture(facture);
    Navigator.of(context).pop(facture);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Préparer la facture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date
            InkWell(
              onTap: () => _pickDate(
                initial: _dateOp,
                onPicked: (d) => setState(() => _dateOp = d),
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de la facture',
                ),
                child: Text(DateFormat('dd.MM.yyyy').format(_dateOp)),
              ),
            ),
            const SizedBox(height: 12),
            // Client dropdown
            DropdownButtonFormField<int>(
              initialValue: _selectedClientId,
              decoration: const InputDecoration(labelText: 'Client à facturer'),
              items: _clients
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.contactId,
                      child: Text(
                        (c as dynamic).nomPrenom ?? c.contactId.toString(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _onClientChanged,
            ),
            const SizedBox(height: 12),
            // Titre
            TextFormField(
              initialValue: _titre,
              decoration: const InputDecoration(labelText: 'Titre'),
              onChanged: (v) => setState(() => _titre = v),
            ),
            const SizedBox(height: 12),
            // Libelle
            TextFormField(
              initialValue: _libelle,
              decoration: const InputDecoration(labelText: 'Libellé'),
              onChanged: (v) => setState(() => _libelle = v),
            ),
            const SizedBox(height: 12),
            // Editable flexgrid (simple ListView for now)
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _contenu.length,
                itemBuilder: (context, i) {
                  final c = _contenu[i];
                  return ListTile(
                    title: Text(c.descriptionTarif ?? ''),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Temps: ${AppHelper.minutesToHours(c.totalMinutes ?? 0)}'),
                        const SizedBox(width: 12),
                        Text('Honoraires: CHF ${c.totalHonoraires?.toStringAsFixed(2) ?? '0.00'}'),
                        const SizedBox(width: 12),
                        Text('Frais: CHF ${c.totalFrais?.toStringAsFixed(2) ?? '0.00'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => FactureContenuEditDialog(
                            initialData: {
                              'descriptionTarif': c.descriptionTarif,
                              'totalHonoraires': c.totalHonoraires,
                              'totalFrais': c.totalFrais,
                              'totalMinutes': c.totalMinutes,
                            },
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _contenu[i] = FactureContenu(
                              codeTarif: c.codeTarif,
                              descriptionTarif: result['descriptionTarif'],
                              montantTarif: c.montantTarif,
                              ordreTarif: c.ordreTarif,
                              totalMinutes: result['totalMinutes'],
                              totalFrais: result['totalFrais'],
                              totalHonoraires: result['totalHonoraires'],
                            );
                            _calculateTotals();
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total honoraires: CHF ${_totalHonoraires.toStringAsFixed(2)}',
                ),
                Text('Total frais: CHF ${_totalFrais.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Grand total: CHF ${_grandTotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 12),
            // Conditions
            TextFormField(
              initialValue: _conditions,
              decoration: const InputDecoration(labelText: 'Conditions'),
              onChanged: (v) => setState(() => _conditions = v),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _onOk, child: const Text('OK')),
          ],
        ),
      ),
    );
  }
  
}

String _serializeContenu(List<FactureContenu> list) {
  return jsonEncode(
    list
        .map(
          (c) => {
            'codeTarif': c.codeTarif,
            'descriptionTarif': c.descriptionTarif,
            'montantTarif': c.montantTarif,
            'ordreTarif': c.ordreTarif,
            'totalMinutes': c.totalMinutes,
            'totalFrais': c.totalFrais,
            'totalHonoraires': c.totalHonoraires,
          },
        )
        .toList(),
  );
}
