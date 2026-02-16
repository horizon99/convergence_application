import 'package:flutter/material.dart';

import '../data/repositories/comptes_repository.dart';
import '../models/compte_model.dart';

class ComptesListScreen extends StatefulWidget {
  const ComptesListScreen({super.key});

  @override
  State<ComptesListScreen> createState() => _ComptesListScreenState();
}

class _ComptesListScreenState extends State<ComptesListScreen> {
  final ComptesRepository _repo = ComptesRepository();
  List<Compte> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repo.getAllComptes();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _delete(Compte c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text('Supprimer ${c.numero} — ${c.libelle} ?'),
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
      await _repo.deleteCompte(c.idCompte ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte supprimé')));
      await _load();
    }
  }

  Future<void> _edit([Compte? compte]) async {
    final numeroCtrl = TextEditingController(text: compte?.numero ?? '');
    final libelleCtrl = TextEditingController(text: compte?.libelle ?? '');
    String categorie = compte?.categorie ?? 'actif';
    bool actif = compte?.actif ?? true;
    final ordreCtrl = TextEditingController(
      text: (compte?.ordre ?? 0).toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(compte == null ? 'Nouveau compte' : 'Éditer le compte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroCtrl,
                decoration: const InputDecoration(labelText: 'Numéro'),
              ),
              TextField(
                controller: libelleCtrl,
                decoration: const InputDecoration(labelText: 'Libellé'),
              ),
              DropdownButtonFormField<String>(
                initialValue: categorie,
                items: const [
                  DropdownMenuItem(value: 'actif', child: Text('actif')),
                  DropdownMenuItem(value: 'passif', child: Text('passif')),
                  DropdownMenuItem(value: 'produit', child: Text('produit')),
                  DropdownMenuItem(value: 'charge', child: Text('charge')),
                ],
                onChanged: (v) => categorie = v ?? categorie,
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
              Row(
                children: [
                  const Text('Actif'),
                  Checkbox(value: actif, onChanged: (v) => actif = v ?? actif),
                ],
              ),
              TextField(
                controller: ordreCtrl,
                decoration: const InputDecoration(labelText: 'Ordre'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final newCompte = Compte(
                idCompte: compte?.idCompte,
                numero: numeroCtrl.text.trim(),
                libelle: libelleCtrl.text.trim(),
                categorie: categorie,
                actif: actif,
                ordre: int.tryParse(ordreCtrl.text) ?? 0,
              );

              if (newCompte.idCompte == null) {
                await _repo.insertCompte(newCompte);
              } else {
                await _repo.updateCompte(newCompte);
              }

              if (!mounted) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptes'),
        actions: [
          IconButton(
            tooltip: 'Nouveau compte',
            icon: const Icon(Icons.add),
            onPressed: () => _edit(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Vertical scroll
              child: SingleChildScrollView(
                // Horizontal scroll for wide tables
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('N°')),
                    DataColumn(label: Text('Libellé')),
                    DataColumn(label: Text('Catégorie')),
                    DataColumn(label: Text('Actif')),
                    DataColumn(label: Text('Ordre')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _items
                      .map(
                        (c) => DataRow(
                          cells: [
                            DataCell(Text(c.numero)),
                            DataCell(Text(c.libelle)),
                            DataCell(Text(c.categorie)),
                            DataCell(Text(c.actif ? 'Oui' : 'Non')),
                            DataCell(Text(c.ordre.toString())),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _edit(c),
                                    tooltip: 'Éditer',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _delete(c),
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              // FloatingActionButton removed — action moved to AppBar
            ),
    );
  }
}
