import 'facture_contenu_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/facture_contenu_model.dart';
import '../models/parties_model.dart';
import '../data/repositories/mediateur_repository.dart';
import '../data/repositories/parties_repository.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../data/repositories/facture_repository.dart';
import '../app_helper.dart';
import 'facture_print_dialog.dart';
import '../reports/facture_service.dart';

class FacturePrepare extends StatefulWidget {
  final int dossierId;
  final DateTime dateDu;
  final DateTime dateAu;
  final Facture? facture;
  const FacturePrepare({
    super.key,
    required this.dossierId,
    required this.dateDu,
    required this.dateAu,
    this.facture,
  });

  @override
  State<FacturePrepare> createState() => _FacturePrepareState();
}

class _FacturePrepareState extends State<FacturePrepare> {
  DateTime _dateOp = DateTime.now();
  int? _selectedClientId;
  //double _participation = 1.0;
  String _titre = 'FACTURE';
  String _libelle = 'Je me permets de vous facturer mes honoraires comme suit:';
  String _conditions =
      'Facture payable net à 30 jours, avec mes remerciements.';
  List<Parties> _clients = [];
  List<FactureContenu> _contenu = [];
  double _totalHonoraires = 0.0;
  double _totalFrais = 0.0;
  double _grandTotal = 0.0;
  double _montantParticipation = 0.0;
  bool _loading = true;
  bool? _paye = false;
  final _participationController = TextEditingController();

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
    final mediateur = await MediateurRepository().getMediateur();
    setState(() {
      _clients = clients.where((p) => p.role == 'Client').toList();
      _contenu = contenu;
      _calculateTotals();
      _participationController.text = '100';
      _libelle =
          mediateur.factureLibelle ??
          'Je me permets de vous facturer mes honoraires comme suit:';
      _conditions = mediateur.factureConditions ?? 'Avec mes remerciements.';
      _loading = false;
    });

    // If we are editing an existing facture, populate fields
    if (widget.facture != null) {
      final f = widget.facture!;
      setState(() {
        _dateOp = f.dateOp;
        _selectedClientId = f.contactID;
        _titre = f.titre ?? _titre;
        _libelle = f.libelle ?? _libelle;
        _conditions = f.conditions ?? _conditions;
        _participationController.text = (f.tauxParticipation ?? 100).toString();
        _contenu = _deserializeContenu(f.contenu);
        _paye = f.paye;
        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    _totalHonoraires = _contenu.fold(
      0.0,
      (sum, c) => sum + (c.totalHonoraires ?? 0),
    );
    _totalFrais = _contenu.fold(0.0, (sum, c) => sum + (c.totalFrais ?? 0));
    _grandTotal = (_totalHonoraires + _totalFrais);
    _montantParticipation =
        ((_participationController.text.isNotEmpty
                    ? double.tryParse(_participationController.text) ?? 100
                    : 100) *
                _grandTotal /
                10)
            .round() /
        10;
  }

  Future<void> _onClientChanged(int? clientId) async {
    if (clientId == null) return;
    final partie = _clients.firstWhere((p) => p.contactId == clientId);
    setState(() {
      _selectedClientId = clientId;
      _participationController.text = (partie.participation ?? 100).toString();
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

  Future<void> _onOk() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: aucun client sélectionné.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final facture = Facture(
      idFacture: widget.facture?.idFacture,
      dateOp: _dateOp,
      dossierID: widget.dossierId,
      contactID: _selectedClientId!,
      titre: _titre,
      libelle: _libelle,
      conditions: _conditions,
      contenu: _serializeContenu(_contenu),
      honoraires: _totalHonoraires,
      frais: _totalFrais,
      total: _grandTotal,
      participation: _montantParticipation,
      tauxParticipation: int.tryParse(_participationController.text) ?? 100,
      activitesDu: widget.dateDu,
      activiteAu: widget.dateAu,
      paye: _paye ?? false,
    );
    int? idInserted = facture.idFacture;
    if (widget.facture == null) {
      // Show print options dialog before saving
      final res = await showDialog<FacturePrintResult?>(
        context: context,
        builder: (context) => FacturePrintDialog(),
      );

      // If user confirmed, insert record and generate PDF
      if (res != null && res.generated) {
        // Save facture to get an ID for PDF generation
        idInserted = await FactureRepository().insertFacture(facture);

        // Fetch activities again to ensure we have the latest data for PDF
        final activites = await ActivitesFacturablesRepository()
            .getActivitesFacturables(
              facture.dossierID,
              dateDu: facture.activitesDu ?? facture.dateOp,
              dateAu: facture.activiteAu ?? facture.dateOp,
            );

        // Generate PDF with the specified options
        if (res.afficherFacture == true || res.afficherReleveActivites == true) {
          await FactureService().generateFacturePDF(
            {},
            idFacture: idInserted,
            afficherFacture: res.afficherFacture,
            afficherQrCode: res.afficherQrCode,
            afficherReleveActivites: res.afficherReleveActivites,
            afficherFrais: res.afficherFrais,
            afficherMontants: res.afficherMontants,
            montantFacture: facture.participation ?? 0.0,
            activites: activites,
            dateDu: facture.activitesDu ?? facture.dateOp,
            dateAu: facture.activiteAu ?? facture.dateOp,
            idDossier: facture.dossierID,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture générée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
    } else {
      await FactureRepository().updateFacture(facture);
      Navigator.of(context).pop(true);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.facture == null ? 'Créer une facture' : 'Éditer la facture',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Flexible(
                  child:
                      // Date
                      InkWell(
                        onTap: () => _pickDate(
                          initial: _dateOp,
                          onPicked: (d) => setState(() => _dateOp = d),
                        ),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date de facturation',
                            filled: true,
                            fillColor: Colors.yellow[50],
                          ),
                          child: Text(DateFormat('dd.MM.yyyy').format(_dateOp)),
                        ),
                      ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: TextFormField(
                    initialValue: _titre,
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      filled: true,
                      fillColor: Colors.yellow[50],
                    ),
                    onChanged: (v) => setState(() => _titre = v),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: CheckboxListTile(
                    value: _paye,
                    title: const Text('Payé'),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (widget.facture == null
                        ? null
                        : (v) {
                            setState(() {
                              _paye = v;
                            });
                          }),
                    enabled: (widget.facture == null) ? false : true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title (sur la même colonne)
            Row(
              children: [
                Flexible(
                  child: // Client dropdown
                  DropdownButtonFormField<int>(
                    initialValue: _selectedClientId,
                    decoration: InputDecoration(
                      labelText: 'Client à facturer',
                      filled: true,
                      fillColor: Colors.yellow[50],
                    ),
                    items: _clients
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.contactId,
                            child: Text(
                              (c as dynamic).nomPrenom ??
                                  c.contactId.toString(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _onClientChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: TextFormField(
                    controller: _participationController,
                    decoration: InputDecoration(
                      labelText: 'Participation (%)',
                      filled: true,
                      fillColor: Colors.yellow[50],
                    ),
                    onChanged: (v) => setState(() {
                      //_participationController.text = (double.tryParse(v) ?? 0).toString();
                      _calculateTotals();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Libellé (sur la même colonne)
            TextFormField(
              initialValue: _libelle,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Libellé',
                filled: true,
                fillColor: Colors.yellow[50],
              ),
              onChanged: (v) => setState(() => _libelle = v),
            ),
            const SizedBox(height: 12),

            const Divider(height: 1, color: Colors.grey),

            ///---------------------------------------
            /// Contenu
            ///---------------------------------------
            Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue[50],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _contenu.length,
                itemBuilder: (context, i) {
                  final c = _contenu[i];
                  return ListTile(
                    title: Text(
                      c.texteFacture ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Temps: ${AppHelper.minutesToHours(c.totalMinutes ?? 0)}',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Honoraires: CHF ${c.totalHonoraires?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Frais: CHF ${c.totalFrais?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => FactureContenuEditDialog(
                            initialData: {
                              'montantTarif': c.montantTarif,
                              'texteFacture': c.texteFacture,
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
                              montantTarif: c.montantTarif,
                              ordreTarif: c.ordreTarif,
                              texteFacture: result['texteFacture'],
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

            // Totaux (sur la même colonne que les Conditions, sous le contenu)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 1),
                Text(
                  'Total honoraires: CHF ${_totalHonoraires.toStringAsFixed(2)}',
                ),
                Text('Total frais: CHF ${_totalFrais.toStringAsFixed(2)}'),
                Text('Montant total: CHF ${_grandTotal.toStringAsFixed(2)}'),
                Text(
                  'Montant participation: CHF ${_montantParticipation.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 1),
              ],
            ),

            const SizedBox(height: 12),
            // Conditions (sur la même colonne)
            TextFormField(
              initialValue: _conditions,
              maxLines: 2,
              scrollController: ScrollController(),
              decoration: InputDecoration(
                labelText: 'Conditions',
                filled: true,
                fillColor: Colors.yellow[50],
              ),
              onChanged: (v) => setState(() => _conditions = v),
            ),

            const SizedBox(height: 24),
            // Bottom actions (sur la même colonne que les Totaux/Participation)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onOk,
                  child: Text(
                    widget.facture == null ? 'Créer facture' : 'Enregistrer',
                  ),
                ),
              ],
            ),
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
            'texteFacture': c.texteFacture,
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

List<FactureContenu> _deserializeContenu(String? jsonStr) {
  if (jsonStr == null || jsonStr.isEmpty) return [];
  try {
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data.map((e) {
      return FactureContenu(
        codeTarif: e['codeTarif']?.toString(),
        texteFacture: e['texteFacture']?.toString(),
        montantTarif: e['montantTarif'] != null
            ? (e['montantTarif'] as num).toDouble()
            : null,
        ordreTarif: e['ordreTarif'] != null
            ? (e['ordreTarif'] as num).toInt()
            : null,
        totalMinutes: e['totalMinutes'] != null
            ? (e['totalMinutes'] as num).toInt()
            : null,
        totalFrais: e['totalFrais'] != null
            ? (e['totalFrais'] as num).toDouble()
            : null,
        totalHonoraires: e['totalHonoraires'] != null
            ? (e['totalHonoraires'] as num).toDouble()
            : null,
      );
    }).toList();
  } catch (_) {
    return [];
  }
}
