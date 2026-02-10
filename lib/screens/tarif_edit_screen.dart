import 'package:flutter/material.dart';

import '../models/tarifs_model.dart';
import '../data/repositories/tarifs_repository.dart';

class TarifEditScreen extends StatefulWidget {
  const TarifEditScreen({super.key});

  @override
  State<TarifEditScreen> createState() => _TarifEditScreenState();
}

class _TarifEditScreenState extends State<TarifEditScreen> {
  final TarifsRepository _repo = TarifsRepository();
  late Future<List<ModeleTarif>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.getAllTarifs();
    });
  }

  Future<void> _showEditDialog({ModeleTarif? tarif}) async {
    final id = tarif?.idTarif;
    final groupeController = TextEditingController(text: tarif?.groupeTarif ?? '');
    final codeController = TextEditingController(text: tarif?.codeTarif ?? '');
    final ordreController = TextEditingController(text: tarif?.ordreTarif.toString() ?? '0');
    final descriptionController = TextEditingController(text: tarif?.descriptionTarif ?? '');
    final texteController = TextEditingController(text: tarif?.texteFacture ?? '');
    final tarifHoraireController = TextEditingController(text: tarif?.tarifHoraire.toString() ?? '0');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Ajouter tarif' : 'Modifier tarif'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: groupeController,
                  decoration: const InputDecoration(labelText: 'Groupe'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code UNIQUE (max 4 caractères)'),
                ),
                TextFormField(
                  controller: ordreController,
                  decoration: const InputDecoration(labelText: 'Ordre de tri dans les relevés'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description sur les relevés'),
                ),
                TextFormField(
                  controller: texteController,
                  decoration: const InputDecoration(labelText: 'Texte sur les factures'),
                ),
                TextFormField(
                  controller: tarifHoraireController,
                  decoration: const InputDecoration(labelText: 'Tarif horaire'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final modele = ModeleTarif(
                idTarif: id,
                groupeTarif: groupeController.text.trim(),
                codeTarif: codeController.text.trim(),
                ordreTarif: int.tryParse(ordreController.text.trim()) ?? 0,
                descriptionTarif: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                texteFacture: texteController.text.trim().isEmpty ? null : texteController.text.trim(),
                tarifHoraire: int.tryParse(tarifHoraireController.text.trim()) ?? 0,
              );

              try {
                if (id == null) {
                  final insertedId = await _repo.insertTarif(modele);
                  if (insertedId > 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarif créé')),
                      );
                    }
                    Navigator.pop(context, true);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur : création échouée')),
                      );
                    }
                  }
                } else {
                  final rows = await _repo.updateTarif(modele);
                  if (rows > 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarif enregistré')),
                      );
                    }
                    Navigator.pop(context, true);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur : aucun changement enregistré')),
                      );
                    }
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur base de données : $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) _load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer tarif'),
        content: const Text('Voulez-vous supprimer ce tarif ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.deleteTarif(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter',
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<ModeleTarif>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: \\${snapshot.error}'));

          final tarifs = snapshot.data ?? [];

          if (tarifs.isEmpty) return const Center(child: Text('Aucun tarif'));

          return ListView.separated(
            itemCount: tarifs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = tarifs[index];
              return ListTile(
                title: Text(t.groupeTarif),
                subtitle: Text('${t.codeTarif} • ${t.descriptionTarif ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(tarif: t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(t.idTarif!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      
    );
  }
}
