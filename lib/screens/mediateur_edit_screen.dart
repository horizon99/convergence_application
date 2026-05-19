import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/mediateur_model.dart';
import '../data/repositories/mediateur_repository.dart';

class MediateurEditScreen extends StatefulWidget {
  const MediateurEditScreen({super.key});

  @override
  State<MediateurEditScreen> createState() => _MediateurEditScreenState();
}

class _MediateurEditScreenState extends State<MediateurEditScreen> {
  final MediateurRepository _repo = MediateurRepository();

  Mediateur? _mediateur;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _localiteController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _factureAdresseController =
      TextEditingController();
  final TextEditingController _factureNoRueController = TextEditingController();
  final TextEditingController _factureNoPostalController =
      TextEditingController();
  final TextEditingController _factureLocaliteController =
      TextEditingController();
  final TextEditingController _factureLibelleController =
      TextEditingController();
  final TextEditingController _factureConditionsController =
      TextEditingController();
  final TextEditingController _enTeteRapportController =
      TextEditingController();
  final TextEditingController _enTetePapierController = TextEditingController();
  final TextEditingController _enTetePapierXController = TextEditingController();
  final TextEditingController _enTetePapierYController = TextEditingController();
  final TextEditingController _logoXController = TextEditingController();
  final TextEditingController _logoYController = TextEditingController();
  final TextEditingController _logoWController = TextEditingController();
  final TextEditingController _logoHController = TextEditingController();
  Uint8List? _logoData;

  bool _tva = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMediateur();
  }

  Future<void> _loadMediateur() async {
    final m = await _repo.getMediateur();
    if (!mounted) return;
    setState(() {
      _mediateur = m;
      _nomController.text = m.nom ?? '';
      _titreController.text = m.titre ?? '';
      _adresseController.text = m.adresse ?? '';
      _localiteController.text = m.localite ?? '';
      _telephoneController.text = m.telephone ?? '';
      _ibanController.text = m.iban ?? '';
      _emailController.text = m.email ?? '';
      _factureAdresseController.text = m.factureAdresse ?? '';
      _factureNoRueController.text = m.factureNoRue ?? '';
      _factureNoPostalController.text = m.factureNoPostal ?? '';
      _factureLocaliteController.text = m.factureLocalite ?? '';
      _factureLibelleController.text = m.factureLibelle ?? '';
      _factureConditionsController.text = m.factureConditions ?? '';
      _enTeteRapportController.text = m.enTeteRapport ?? '';
      _enTetePapierController.text = m.enTetePapier ?? '';
      _enTetePapierXController.text = m.enTetePapierX?.toString() ?? '';
      _enTetePapierYController.text = m.enTetePapierY?.toString() ?? '';
      _logoData = m.logo;
      _logoXController.text = m.logoX?.toString() ?? '';
      _logoYController.text = m.logoY?.toString() ?? '';
      _logoWController.text = m.logoW?.toString() ?? '';
      _logoHController.text = m.logoH?.toString() ?? '';
      _tva = m.tva ?? false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _titreController.dispose();
    _adresseController.dispose();
    _localiteController.dispose();
    _telephoneController.dispose();
    _ibanController.dispose();
    _emailController.dispose();
    _factureAdresseController.dispose();
    _factureNoRueController.dispose();
    _factureNoPostalController.dispose();
    _factureLocaliteController.dispose();
    _factureLibelleController.dispose();
    _factureConditionsController.dispose();
    _enTeteRapportController.dispose();
    _enTetePapierController.dispose();
    _enTetePapierXController.dispose();
    _enTetePapierYController.dispose();
    _logoXController.dispose();
    _logoYController.dispose();
    _logoWController.dispose();
    _logoHController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_mediateur == null) return;

    final updated = Mediateur(
      idMediateur: _mediateur!.idMediateur,
      nom: _nomController.text.trim(),
      titre: _titreController.text.trim(),
      adresse: _adresseController.text.trim(),
      tva: _tva,
      enTeteRapport: _enTeteRapportController.text.trim().isEmpty
          ? null
          : _enTeteRapportController.text.trim(),
      localite: _localiteController.text.trim().isEmpty
          ? null
          : _localiteController.text.trim(),
        logo: _logoData,
        logoX: _logoXController.text.trim().isEmpty
          ? null
          : int.tryParse(_logoXController.text.trim()),
        logoY: _logoYController.text.trim().isEmpty
          ? null
          : int.tryParse(_logoYController.text.trim()),
        logoW: _logoWController.text.trim().isEmpty
          ? null
          : int.tryParse(_logoWController.text.trim()),
        logoH: _logoHController.text.trim().isEmpty
          ? null
          : int.tryParse(_logoHController.text.trim()),
      enTetePapier: _enTetePapierController.text.trim().isEmpty
          ? null
          : _enTetePapierController.text.trim(),
      enTetePapierX: _enTetePapierXController.text.trim().isEmpty
          ? null
          : int.tryParse(_enTetePapierXController.text.trim()),
      enTetePapierY: _enTetePapierYController.text.trim().isEmpty
          ? null
          : int.tryParse(_enTetePapierYController.text.trim()),
      factureAdresse: _factureAdresseController.text.trim().isEmpty
          ? null
          : _factureAdresseController.text.trim(),
      factureNoRue: _factureNoRueController.text.trim().isEmpty
          ? null
          : _factureNoRueController.text.trim(),
      factureNoPostal: _factureNoPostalController.text.trim().isEmpty
          ? null
          : _factureNoPostalController.text.trim(),
      factureLocalite: _factureLocaliteController.text.trim().isEmpty
          ? null
          : _factureLocaliteController.text.trim(),
      factureLibelle: _factureLibelleController.text.trim().isEmpty
          ? null
          : _factureLibelleController.text.trim(),
      factureConditions: _factureConditionsController.text.trim().isEmpty
          ? null
          : _factureConditionsController.text.trim(),
      telephone: _telephoneController.text.trim().isEmpty
          ? null
          : _telephoneController.text.trim(),
      iban: _ibanController.text.trim().isEmpty
          ? null
          : _ibanController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    final rows = await _repo.updateMediateur(updated);

    if (!mounted) return;

    if (rows > 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune modification enregistrée')),
      );
    }
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      setState(() {
        _logoData = bytes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement image: $e')),
      );
    }
  }

  void _removeLogo() {
    setState(() {
      _logoData = null;
      _logoXController.text = '';
      _logoYController.text = '';
      _logoWController.text = '';
      _logoHController.text = '';
      _enTetePapierXController.text = '';
      _enTetePapierYController.text = ''; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres du professionnel')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row: Nom | Titre | En-tête rapport
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(labelText: 'Nom'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _titreController,
                          decoration: const InputDecoration(labelText: 'Titre professionnel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _enTetePapierController,
                          decoration: const InputDecoration(
                            labelText: 'Nom sur l\'en-tête papier',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _enTeteRapportController,
                          decoration: const InputDecoration(
                            labelText: 'En-tête du rapport',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _enTetePapierXController,
                          decoration: const InputDecoration(labelText: 'Position en-tête papier X (cm)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _enTetePapierYController,
                          decoration: const InputDecoration(labelText: 'Position en-tête papier Y (cm)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _adresseController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse du papier à en-tête',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _localiteController,
                          decoration: const InputDecoration(
                            labelText: 'Localité du papier à lettre',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CheckboxListTile(
                          value: _tva,
                          onChanged: (v) => setState(() => _tva = v ?? false),
                          title: const Text('Soumis TVA'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row: Téléphone | Email | IBAN
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _telephoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _ibanController,
                          decoration: const InputDecoration(labelText: 'IBAN'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Logo preview + controls
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _logoData == null
                            ? const Center(child: Text('Aucun logo'))
                            : Image.memory(_logoData!, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickLogo,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Charger'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _logoData == null ? null : _removeLogo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Supprimer'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _logoXController,
                                    decoration: const InputDecoration(labelText: 'Position logo X (cm)'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _logoYController,
                                    decoration: const InputDecoration(labelText: 'Position logo Y (cm)'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _logoWController,
                                    decoration: const InputDecoration(labelText: 'Largeur logo (cm)'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _logoHController,
                                    decoration: const InputDecoration(labelText: 'Hauteur logo (cm)'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.yellow.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Paramètres pour les factures',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _factureAdresseController,
                                decoration: const InputDecoration(
                                  labelText: 'Adresse pour factures',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _factureNoRueController,
                                decoration: const InputDecoration(
                                  labelText: 'No / Rue',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _factureNoPostalController,
                                decoration: const InputDecoration(
                                  labelText: 'No postal',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _factureLocaliteController,
                                decoration: const InputDecoration(
                                  labelText: 'Localité',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _factureLibelleController,
                          decoration: const InputDecoration(
                            labelText: 'Libellé pour factures',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _factureConditionsController,
                          decoration: const InputDecoration(
                            labelText: 'Conditions de facturation',
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _save,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Text('Enregistrer'),
          ),
        ),
      ),
    );
  }
}
