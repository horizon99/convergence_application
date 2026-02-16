import 'package:flutter/material.dart';

import '../data/repositories/ecritures_repository.dart';
import '../data/repositories/comptes_repository.dart';
import '../models/ecriture_model.dart';
import '../models/compte_model.dart';
import '../app_helper.dart';

class EcritureesListScreen extends StatefulWidget {
  const EcritureesListScreen({super.key});

  @override
  State<EcritureesListScreen> createState() => _EcritureesListScreenState();
}

class _EcritureesListScreenState extends State<EcritureesListScreen> {
  final EcrituresRepository _repo = EcrituresRepository();
  final ComptesRepository _comptesRepo = ComptesRepository();
  List<Ecriture> _items = [];
  Map<int, String> _compteLabels = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repo.getAll();
    // load comptes labels
    final comptes = await _comptesRepo.getAllComptes();
    _compteLabels = {for (var c in comptes) (c.idCompte ?? 0): c.libelle};
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _delete(Ecriture e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'écriture'),
        content: Text('Supprimer l\'écriture du ${_formatDate(e.date)} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (ok == true) {
      await _repo.delete(e.id ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écriture supprimée')));
      await _load();
    }
  }

  Future<void> _edit([Ecriture? ecriture]) async {
    // Load comptes lists for dropdowns
    final comptesRepo = ComptesRepository();
    final charges = await comptesRepo.getAllComptesChargesProduits();
    final actifs = await comptesRepo.getAllComptesActifsPassifs();

    DateTime initialDate = ecriture?.date ?? DateTime.now();
    String formatDdMmYyyy(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    final dateCtrl = TextEditingController(text: formatDdMmYyyy(initialDate));
    int? selectedCharge = ecriture?.compteChargeProduitId;
    int? selectedActif = ecriture?.compteActifPassifId;
    String nature = ecriture?.nature ?? 'recette';
    final montantCtrl = TextEditingController(text: (ecriture?.montant ?? 0.0).toString());
    final descriptionCtrl = TextEditingController(text: ecriture?.description ?? '');
    final factureCtrl = TextEditingController(text: ecriture?.factureId?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(ecriture == null ? 'Nouvelle écriture' : 'Éditer écriture'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (dd.MM.yyyy)')),

                // Compte charge/produit dropdown
                DropdownButtonFormField<int>(
                  value: selectedCharge,
                  items: charges
                      .map((Compte c) => DropdownMenuItem<int>(value: c.idCompte, child: Text(c.libelle)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCharge = v),
                  decoration: const InputDecoration(labelText: 'Compte charge/produit'),
                ),

                // Compte actif/passif dropdown
                DropdownButtonFormField<int>(
                  value: selectedActif,
                  items: actifs
                      .map((Compte c) => DropdownMenuItem<int>(value: c.idCompte, child: Text(c.libelle)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedActif = v),
                  decoration: const InputDecoration(labelText: 'Compte actif/passif'),
                ),

                DropdownButtonFormField<String>(
                  value: nature,
                  items: const [
                    DropdownMenuItem(value: 'recette', child: Text('recette')),
                    DropdownMenuItem(value: 'depense', child: Text('depense')),
                  ],
                  onChanged: (v) => setState(() => nature = v ?? nature),
                  decoration: const InputDecoration(labelText: 'Nature'),
                ),

                TextField(controller: montantCtrl, decoration: const InputDecoration(labelText: 'Montant'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
                TextField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: factureCtrl, decoration: const InputDecoration(labelText: 'Facture id'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                DateTime? parsedDate = AppHelper.parseDateString(dateCtrl.text);
                if (parsedDate == null) parsedDate = DateTime.now();

                final newE = Ecriture(
                  id: ecriture?.id,
                  date: parsedDate,
                  compteChargeProduitId: selectedCharge ?? 0,
                  compteActifPassifId: selectedActif ?? 0,
                  nature: nature,
                  montant: double.tryParse(montantCtrl.text) ?? 0.0,
                  description: descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
                  factureId: factureCtrl.text.trim().isEmpty ? null : int.tryParse(factureCtrl.text),
                  createdAt: ecriture?.createdAt,
                  updatedAt: DateTime.now(),
                );

                if (newE.id == null) {
                  await _repo.insert(newE);
                } else {
                  await _repo.update(newE);
                }

                if (!mounted) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Écritures'),
        actions: [
          IconButton(
            tooltip: 'Nouvelle écriture',
            icon: const Icon(Icons.add),
            onPressed: () => _edit(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Compte C/P')),
                    DataColumn(label: Text('Compte A/P')),
                    DataColumn(label: Text('Nature')),
                    DataColumn(label: Text('Montant')),
                    DataColumn(label: Text('Desc')),
                    DataColumn(label: Text('Facture')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _items
                      .map(
                        (e) => DataRow(cells: [
                          DataCell(Text(_formatDate(e.date))),
                          DataCell(Text(_compteLabels[e.compteChargeProduitId] ?? e.compteChargeProduitId.toString())),
                          DataCell(Text(_compteLabels[e.compteActifPassifId] ?? e.compteActifPassifId.toString())),
                          DataCell(Text(e.nature)),
                          DataCell(Text(e.montant.toStringAsFixed(2))),
                          DataCell(Text(e.description ?? '')),
                          DataCell(Text(e.factureId?.toString() ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _edit(e),
                                tooltip: 'Éditer',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(e),
                                tooltip: 'Supprimer',
                              ),
                            ],
                          )),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }
}
