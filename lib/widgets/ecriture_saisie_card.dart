import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_helper.dart';
import '../data/repositories/comptes_repository.dart';
import '../data/repositories/ecritures_repository.dart';
import '../data/repositories/facture_repository.dart';
import '../models/compte_model.dart';
import '../models/ecriture_model.dart';
import '../models/facture_model.dart';

class EcritureSaisieCard extends StatefulWidget {
  final VoidCallback? onSaved;

  const EcritureSaisieCard({super.key, this.onSaved});

  @override
  State<EcritureSaisieCard> createState() => _EcritureSaisieCardState();
}

class _EcritureSaisieCardState extends State<EcritureSaisieCard> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCharge;
  int? _selectedActif;
  String _nature = 'recette';
  final _montantCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: DateFormat('dd.MM.yyyy').format(DateTime.now()));
  int? _selectedFactureId;

  late Future<List<Compte>> _chargesFuture;
  late Future<List<Compte>> _actifsFuture;
  late Future<List<FacturesForDropdown>> _facturesFuture;

  @override
  void initState() {
    super.initState();
    _chargesFuture = ComptesRepository().getAllComptesChargesProduits();
    _actifsFuture = ComptesRepository().getAllComptesActifsPassifs();
    _facturesFuture = FactureRepository().getFacturesForDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // première ligne: Date, compte Actif/Passif, compte Charge/Produit, sens
              Row(
                children: [
                  // DATE
                  Expanded(
                    flex: 2,
                    child: TextField(controller: _dateCtrl, decoration: const InputDecoration(labelText: 'Date (jj.mm.aaaa)'                    )),
                  ),

                  const SizedBox(width: 8),

                  // COMPTE ACTIF/PASSIF
                  Expanded(
                    flex: 3,
                    child: FutureBuilder<List<Compte>>(
                      future: _actifsFuture,
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedActif,
                          items: snap.data!.map((c) => DropdownMenuItem<int>(value: c.idCompte, child: Text(c.libelle))).toList(),
                          onChanged: (v) => setState(() => _selectedActif = v),
                          decoration: const InputDecoration(labelText: 'Compte A/P', border: OutlineInputBorder()),
                          validator: (v) => v == null ? 'Requis' : null,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // COMPTE CHARGE/PRODUIT
                  Expanded(
                    flex: 3,
                    child: FutureBuilder<List<Compte>>(
                      future: _chargesFuture,
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedCharge,
                          items: snap.data!.map((c) => DropdownMenuItem<int>(value: c.idCompte, child: Text(c.libelle))).toList(),
                          onChanged: (v) => setState(() => _selectedCharge = v),
                          decoration: const InputDecoration(labelText: 'Compte C/P', border: OutlineInputBorder()),
                          validator: (v) => v == null ? 'Requis' : null,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // NATURE
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _nature,
                      items: const [
                        DropdownMenuItem(value: 'recette', child: Text('recette')),
                        DropdownMenuItem(value: 'depense', child: Text('depense')),
                      ],
                      onChanged: (v) => setState(() => _nature = v ?? _nature),
                      decoration: const InputDecoration(labelText: 'Nature', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // deuxième ligne: libellé, montant, facture, bouton enregistrer
              Row(
                children: [
                  // DESCRIPTION / LIBELLÉ
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(labelText: 'Libellé', border: OutlineInputBorder()),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // MONTANT
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _montantCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder()),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$'))],
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // FACTURE
                  Expanded(
                    flex: 4,
                    child: FutureBuilder<List<FacturesForDropdown>>(
                      future: _facturesFuture,
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
                        final items = snap.data!
                            .map((fp) => DropdownMenuItem<int?>(
                                  value: fp.idFacture,
                                  child: Text('${DateFormat('dd.MM.yyyy').format(fp.dateOp)} - ${fp.nomContact} - ${fp.montantParticipation.toStringAsFixed(2)}'),
                                ))
                            .toList();
                        items.insert(0, const DropdownMenuItem<int?>(value: null, child: Text('')));
                        return DropdownButtonFormField<int?>(
                          initialValue: _selectedFactureId,
                          items: items,
                          onChanged: (v) => setState(() => _selectedFactureId = v),
                          decoration: const InputDecoration(labelText: 'Facture', border: OutlineInputBorder()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // BOUTON SAVE
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final parsedDate = AppHelper.parseDateString(_dateCtrl.text);
                        final montant = double.tryParse(_montantCtrl.text) ?? 0.0;

                        final e = Ecriture(
                          id: null,
                          date: parsedDate ?? DateTime.now(),
                          compteChargeProduitId: _selectedCharge ?? 0,
                          compteActifPassifId: _selectedActif ?? 0,
                          nature: _nature,
                          montant: montant,
                          description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
                          factureId: _selectedFactureId,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        try {
                          await EcrituresRepository().insert(e);

                          // reset
                          _formKey.currentState!.reset();
                          _montantCtrl.clear();
                          _descriptionCtrl.clear();
                          setState(() {
                            _dateCtrl.text = DateFormat('dd.MM.yyyy').format(DateTime.now());
                            _selectedCharge = null;
                            _selectedActif = null;
                            _nature = 'recette';
                            _selectedFactureId = null;
                          });

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écriture enregistrée'), backgroundColor: Colors.green));
                          // notify parent to refresh list
                          widget.onSaved?.call();
                        } catch (err) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $err'), backgroundColor: Colors.red));
                        }
                      },
                      child: const Icon(Icons.save),
                    ),
                  ),
                ],
              ),
              ]
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }
}
