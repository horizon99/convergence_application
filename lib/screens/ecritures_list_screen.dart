import 'package:flutter/material.dart';
import '../data/repositories/ecritures_repository.dart';
import '../data/repositories/comptes_repository.dart';
import '../data/repositories/facture_repository.dart';
import '../widgets/ecriture_saisie_card.dart';
import '../models/ecriture_model.dart';
import '../models/compte_model.dart';
import '../app_helper.dart';
import '../reports/compte_report.dart';
import '../reports/grand_livre_report.dart';

class EcritureesListScreen extends StatefulWidget {
  const EcritureesListScreen({super.key});

  @override
  State<EcritureesListScreen> createState() => _EcritureesListScreenState();
}

class _EcritureesListScreenState extends State<EcritureesListScreen> {
  final EcrituresRepository _repo = EcrituresRepository();
  final ComptesRepository _comptesRepo = ComptesRepository();
  List<Ecriture> _items = [];
  List<Ecriture> _allItems = [];
  Map<int, String> _compteLabels = {};
  Map<int, String> _compteNumeros = {};
  List<Compte> _charges = [];
  List<Compte> _actifs = [];
  List<int> _years = [];

  int? _selectedYear;
  int? _selectedChargeId;
  int? _selectedActifId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repo.getAll();
    // load comptes lists for filters
    final charges = await _comptesRepo.getAllComptesChargesProduits();
    final actifs = await _comptesRepo.getAllComptesActifsPassifs();
    // load comptes labels
    final comptes = await _comptesRepo.getAllComptes();
    _compteLabels = {for (var c in comptes) (c.idCompte ?? 0): c.libelle};
    _compteNumeros = {for (var c in comptes) (c.idCompte ?? 0): c.numero};
    if (!mounted) return;
    // compute years
    final yearsSet = <int>{};
    for (var e in items) {
      yearsSet.add(e.date.year);
    }
    final years = yearsSet.toList()..sort((b, a) => a.compareTo(b));

    setState(() {
      _allItems = items;
      _charges = charges;
      _actifs = actifs;
      _years = years;
      // preselect most recent year when available
      _selectedYear = years.isNotEmpty ? years.first : null;
      // reset other filters
      _selectedChargeId = null;
      _selectedActifId = null;
      // apply initial year filter to displayed items
      _items = _selectedYear != null ? _allItems.where((e) => e.date.year == _selectedYear).toList() : _allItems;
      _loading = false;
    });
  }

  void _applyFilter() {
    var filtered = _allItems;
    if (_selectedYear != null) {
      filtered = filtered.where((e) => e.date.year == _selectedYear).toList();
    }
    if (_selectedChargeId != null) {
      filtered = filtered
          .where((e) => e.compteChargeProduitId == _selectedChargeId)
          .toList();
    }
    if (_selectedActifId != null) {
      filtered = filtered
          .where((e) => e.compteActifPassifId == _selectedActifId)
          .toList();
    }

    setState(() {
      _items = filtered;
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _delete(Ecriture e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'écriture'),
        content: Text('Supprimer l\'écriture du ${_formatDate(e.date)} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _repo.delete(e.id ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Écriture supprimée')));
      await _load();
    }
  }

  Future<void> _edit([Ecriture? ecriture]) async {
    // Load comptes lists for dropdowns
    final comptesRepo = ComptesRepository();
    final charges = await comptesRepo.getAllComptesChargesProduits();
    final actifs = await comptesRepo.getAllComptesActifsPassifs();
    // Load factures for facture dropdown (date, contact name, participation), sorted by paye
    final factures = await FactureRepository().getFacturesForDropdown();

    DateTime initialDate = ecriture?.date ?? DateTime.now();
    String formatDdMmYyyy(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    final dateCtrl = TextEditingController(text: formatDdMmYyyy(initialDate));
    int? selectedCharge = ecriture?.compteChargeProduitId;
    int? selectedActif = ecriture?.compteActifPassifId;
    String nature = ecriture?.nature ?? 'recette';
    final montantCtrl = TextEditingController(
      text: (ecriture?.montant ?? 0.0).toString(),
    );
    final descriptionCtrl = TextEditingController(
      text: ecriture?.description ?? '',
    );
    int? selectedFactureId = ecriture?.factureId;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            ecriture == null ? 'Nouvelle écriture' : 'Éditer écriture',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // première ligne: Date, compte Actif/Passif, compte Charge/Produit, sens
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: dateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Date (dd.MM.yyyy)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedActif,
                        items: actifs
                            .map(
                              (Compte c) => DropdownMenuItem<int>(
                                value: c.idCompte,
                                child: Text(c.libelle),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedActif = v),
                        decoration: const InputDecoration(
                          labelText: 'Compte A/P',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedCharge,
                        items: charges
                            .map(
                              (Compte c) => DropdownMenuItem<int>(
                                value: c.idCompte,
                                child: Text(c.libelle),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedCharge = v),
                        decoration: const InputDecoration(
                          labelText: 'Compte C/P',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: nature,
                        items: const [
                          DropdownMenuItem(
                            value: 'recette',
                            child: Text('recette'),
                          ),
                          DropdownMenuItem(
                            value: 'depense',
                            child: Text('depense'),
                          ),
                        ],
                        onChanged: (v) => setState(() => nature = v ?? nature),
                        decoration: const InputDecoration(labelText: 'Nature'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // deuxième ligne: libellé, montant
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: descriptionCtrl,
                        decoration: const InputDecoration(labelText: 'Libellé'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: montantCtrl,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                // troisième ligne: facture, bouton enregistrer
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<int?>(
                        initialValue: selectedFactureId,
                        items: factures
                            .map(
                              (fp) => DropdownMenuItem<int?>(
                                value: fp.idFacture,
                                child: Text(
                                  '${_formatDate(fp.dateOp)} - ${fp.nomContact} - ${fp.montantParticipation.toStringAsFixed(2)}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedFactureId = v),
                        decoration: const InputDecoration(labelText: 'Facture'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? parsedDate = AppHelper.parseDateString(
                            dateCtrl.text,
                          );
                          parsedDate ??= DateTime.now();
                          final newE = Ecriture(
                            id: ecriture?.id,
                            date: parsedDate,
                            compteChargeProduitId: selectedCharge ?? 0,
                            compteActifPassifId: selectedActif ?? 0,
                            nature: nature,
                            montant: double.tryParse(montantCtrl.text) ?? 0.0,
                            description: descriptionCtrl.text.trim().isEmpty
                                ? null
                                : descriptionCtrl.text.trim(),
                            factureId: selectedFactureId,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    // compute totals for displayed items
    final double totalRecettes = _items
        .where((e) => e.nature == 'recette')
        .fold(0.0, (s, e) => s + e.montant);
    final double totalDepenses = _items
        .where((e) => e.nature == 'depense')
        .fold(0.0, (s, e) => s + e.montant);
    final double netTotal = totalRecettes - totalDepenses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Écritures'),
        backgroundColor: Colors.blue[50],
        actions: [
          // Year dropdown
          if (_years.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                children: [
                  const Text('Exercice:'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    //decoration: BoxDecoration(color: const Color(0xFFB3E5FC), borderRadius: BorderRadius.circular(6.0)),
                    child: DropdownButton<int?>(
                      value: _selectedYear,
                      hint: const Text('Année'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Tout'),
                        ),
                        ..._years.map(
                          (y) => DropdownMenuItem<int?>(
                            value: y,
                            child: Text(y.toString()),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedYear = v),
                      underline: const SizedBox.shrink(),
                      //dropdownColor: const Color(0xFFB3E5FC),
                    ),
                  ),
                ],
              ),
            ),

          // Compte charge/produit dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              children: [
                const Text('Compte actif/passif:'),

                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  //decoration: BoxDecoration(color: const Color(0xFFB3E5FC), borderRadius: BorderRadius.circular(6.0)),
                  child: DropdownButton<int?>(
                    value: _selectedActifId,
                    hint: const Text('A/P'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tout'),
                      ),
                      ..._actifs.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.idCompte,
                          child: Text(c.libelle),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedActifId = v),
                    underline: const SizedBox.shrink(),
                    //dropdownColor: const Color(0xFFB3E5FC),
                  ),
                ),
              ],
            ),
          ),

          // Compte actif/passif dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              children: [
                const Text('Compte charges/produits:'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  //decoration: BoxDecoration(color: const Color(0xFFB3E5FC), borderRadius: BorderRadius.circular(6.0)),
                  child: DropdownButton<int?>(
                    value: _selectedChargeId,
                    hint: const Text('C/P'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tout'),
                      ),
                      ..._charges.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.idCompte,
                          child: Text(c.libelle),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedChargeId = v),
                    underline: const SizedBox.shrink(),
                    //dropdownColor: const Color(0xFFB3E5FC),
                  ),
                ),
              ],
            ),
          ),

          // Filtrer button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
              ),
              onPressed: _applyFilter,
              child: const Text('Filtrer'),
            ),
          ),
          // Compte / Rapport button (à droite de Filtrer) with validation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Validation: must have a specific year, and exactly one of A/P or C/P selected
                if (_selectedYear == null) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Erreur'),
                      content: const Text(
                        'Veuillez sélectionner une année de travail.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                final bool hasActif = _selectedActifId != null;
                final bool hasCharge = _selectedChargeId != null;
                if (!(hasActif ^ hasCharge)) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Erreur'),
                      content: const Text(
                        'Veuillez sélectionner soit un compte A/P, soit un compte C/P (ni les deux, ni aucun).',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // determine selected account id and name (either Actif/Passif or Charge/Produit)
                final int selectedId = _selectedActifId ?? _selectedChargeId ?? 0;
                final String selectedName = _compteLabels[selectedId] ?? '';
                final String selectedNumero = _compteNumeros[selectedId] ?? '';
                final String selectedAccountDisplay = '$selectedNumero - $selectedName';

                try {
                  await exportCompteReportPdfToFile(
                    _items,
                    _compteLabels,
                    selectedAccountDisplay,
                    fileName: 'releve_${selectedNumero}_${_selectedYear ?? ''}.pdf',
                  );
                } catch (ex, st) {
                  // Log full error and stacktrace to console for debugging
                  // and show it to the user so we can identify the source.
                  // In release builds you may want to hide the stacktrace.
                  // ignore: avoid_print
                  print('Erreur génération PDF: $ex\n$st');
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Erreur'),
                      content: SingleChildScrollView(
                        child: Text('Erreur lors de la génération du PDF:\n$ex\n\n$st'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Extrait'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(),
          ), // spacer
          //IconButton(
          //  tooltip: 'Nouvelle écriture',
          //  icon: const Icon(Icons.add),
          //  onPressed: () => _edit(),
          //),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // saisie card en haut
                  ExpansionTile(
                    title: const Text('Saisies d\'écritures'),
                    children: [
                      EcritureSaisieCard(onSaved: _load),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: SizedBox.shrink()),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Compte A/P')),
                        DataColumn(label: Text('Compte C/P')),
                        DataColumn(label: Text('Nature')),
                        DataColumn(label: Text('Libellé')),
                        DataColumn(label: Text('Montant')),
                        DataColumn(label: Text('Facture')),
                      ],
                      rows: _items
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                        onPressed: () => _edit(e),
                                        tooltip: 'Éditer',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        onPressed: () => _delete(e),
                                        tooltip: 'Supprimer',
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(_formatDate(e.date))),
                                DataCell(
                                  Text(
                                    _compteLabels[e.compteActifPassifId] ??
                                        e.compteActifPassifId.toString(),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _compteLabels[e.compteChargeProduitId] ??
                                        e.compteChargeProduitId.toString(),
                                  ),
                                ),
                                DataCell(Text(e.nature)),
                                DataCell(Text(e.description ?? '')),
                                DataCell(Text(e.montant.toStringAsFixed(2))),
                                DataCell(Text(e.factureId?.toString() ?? '')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text('Grand livre'),
              onPressed: () async {
                // Require a selected year for the Grand Livre export
                if (_selectedYear == null) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Erreur'),
                      content: const Text('Veuillez sélectionner une année dans la barre d\'outils.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                      ],
                    ),
                  );
                  return;
                }

                // Always export entries filtered by the selected year (ignore other UI filters)
                final itemsToExport = _allItems.where((e) => e.date.year == _selectedYear).toList();

                if (itemsToExport.isEmpty) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Information'),
                      content: const Text('Aucune écriture pour l\'année sélectionnée.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                      ],
                    ),
                  );
                  return;
                }

                try {
                  await exportGrandLivreReportPdfToFile(
                    itemsToExport,
                    _compteLabels,
                    _compteNumeros,
                    fileName: 'grand_livre_${_selectedYear}_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  );
                } catch (ex, st) {
                  // ignore: avoid_print
                  print('Erreur génération Grand Livre PDF: $ex\n$st');
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Erreur'),
                      content: SingleChildScrollView(child: Text('Erreur lors de la génération du PDF:\n$ex\n\n$st')),
                      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 12),
            const Spacer(),
            Text(
              'Total: ${netTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: netTotal >= 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
