import 'package:flutter/material.dart';
import '../models/dossier.dart';
import '../models/priorite.dart';
import '../data/repositories/priorite_repository.dart';
import '../data/repositories/dossier_repository.dart';

class DossierDetailScreen extends StatefulWidget {
  final Dossier dossier;

  const DossierDetailScreen({super.key, required this.dossier});

  @override
  State<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends State<DossierDetailScreen> {
  final PrioriteRepository prioriteRepository = PrioriteRepository();
  final DossierRepository dossierRepository = DossierRepository();

  Color prioriteColorFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'a traiter':
        return Colors.orange;
      case 'en attente':
        return Colors.green;
      case 'a encaisser':
        return Colors.purple;
      case 'a archiver':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  late int _selectedPrioriteId;
  late Future<List<Priorite>> _prioritesFuture;

  late TextEditingController _libelleController;
  late TextEditingController _tarifController;
  late TextEditingController _tvaController;
  late TextEditingController _afaireController;
  late TextEditingController _refTribController;
  late TextEditingController _dateCreationController;
  late TextEditingController _dateArchiveController;
  late TextEditingController _noArchiveController;
  late bool _archive;

  DateTime? parseDateString(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;

    // Try ISO first
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso;

    // Try common local formats: dd.MM.yyyy or dd/MM/yyyy or dd-MM-yyyy
    final parts = v.split(RegExp(r'[.\-\/]'));
    if (parts.length >= 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    String formatDate(DateTime? d) {
      if (d == null) return '';
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yyyy = d.year.toString();
      return '$dd.$mm.$yyyy';
    }

    _selectedPrioriteId = widget.dossier.prioriteId;
    _prioritesFuture = prioriteRepository.getAllPriorites();
    _libelleController = TextEditingController(text: widget.dossier.libelle);
    _tarifController = TextEditingController(
      text: widget.dossier.tarif.toString(),
    );
    _tvaController = TextEditingController(
      text: widget.dossier.tva?.toString() ?? '',
    );
    _afaireController = TextEditingController(
      text: widget.dossier.afaire ?? '',
    );
    _refTribController = TextEditingController(
      text: widget.dossier.refTribunal ?? '',
    );
    _dateCreationController = TextEditingController(
      text: formatDate(widget.dossier.dateCreation),
    );
    _dateArchiveController = TextEditingController(
      text: formatDate(widget.dossier.dateArchive),
    );
    _archive = widget.dossier.archive;
    _noArchiveController = TextEditingController(
      text: widget.dossier.noArchive?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _tarifController.dispose();
    _tvaController.dispose();
    _afaireController.dispose();
    _refTribController.dispose();
    _noArchiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─────────────────────────────
            /// Ligne 1 : Libellé + Priorité
            /// ─────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    style:TextStyle(fontWeight: FontWeight.bold),
                    controller: _libelleController,
                    decoration: const InputDecoration(
                      labelText: 'Libellé',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFFFFFCC),
                      filled: true,)
                    ),
                  ),
                
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FutureBuilder<List<Priorite>>(
                    future: _prioritesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 56,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final priorites = snapshot.data!;

                      final currentLabel = priorites
                          .firstWhere(
                            (p) => p.id == _selectedPrioriteId,
                            orElse: () => priorites.first,
                          )
                          .label;
                      final color = prioriteColorFromLabel(currentLabel);

                      return DropdownButtonFormField<int>(
                        initialValue: _selectedPrioriteId,
                        decoration: InputDecoration(
                          labelText: 'Priorité',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: color.withAlpha(30),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: color),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: color, width: 2),
                          ),
                        ),
                        style: TextStyle(color: color),
                        iconEnabledColor: color,
                        items: priorites.map((p) {
                          final itemColor = prioriteColorFromLabel(p.label);
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.label,
                              style: TextStyle(color: itemColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPrioriteId = value!;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ─────────────────────────────
            /// Ligne 2 : À faire
            /// ─────────────────────────────
            TextFormField(
              controller: _afaireController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'À faire',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFCCCCFF),
                filled: true,
              ),
            ),

            const SizedBox(height: 16),

            /// ─────────────────────────────
            /// Bloc rétractable : infos complémentaires
            /// ─────────────────────────────
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: const Text('Informations complémentaires'),
                leading: const Icon(Icons.add),
                childrenPadding: const EdgeInsets.all(10),
                children: [
                  Column(
                    spacing: 15,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateCreationController,
                              decoration: const InputDecoration(
                                labelText: 'Date création',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _refTribController,
                              decoration: const InputDecoration(
                                labelText: 'Réf. tribunal',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tarifController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tarif',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tvaController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'TVA',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: CheckboxListTile(
                              value: _archive,
                              onChanged: (value) {
                                setState(() {
                                  _archive = value ?? false;
                                });
                              },
                              title: const Text('Archivé'),
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _dateArchiveController,
                              decoration: const InputDecoration(
                                labelText: 'Date archivage',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _noArchiveController,
                              decoration: const InputDecoration(
                                labelText: 'No archivage',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 0),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton Enregistrer
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final priorites = await _prioritesFuture;
                final selectedPrioriteLabel = priorites
                    .firstWhere(
                      (p) => p.id == _selectedPrioriteId,
                      orElse: () => priorites.first,
                    )
                    .label;
                final updated = Dossier(
                  id: widget.dossier.id,
                  libelle: _libelleController.text.trim(),
                  tarif: int.tryParse(_tarifController.text.trim()) ?? 0,
                  tva: _tvaController.text.trim().isEmpty
                      ? null
                      : double.tryParse(_tvaController.text.trim()),
                  prioriteId: _selectedPrioriteId,
                  prioriteLabel: selectedPrioriteLabel,
                  afaire: _afaireController.text.trim().isEmpty
                      ? null
                      : _afaireController.text.trim(),
                  dateCreation: parseDateString(_dateCreationController.text),
                  dateArchive: parseDateString(_dateArchiveController.text),
                    noArchive: _noArchiveController.text.trim().isEmpty
                      ? null
                      : int.tryParse(_noArchiveController.text.trim()),
                  archive: _archive,
                  refTribunal: _refTribController.text.trim().isEmpty
                      ? null
                      : _refTribController.text.trim(),
                );

                final rows = await dossierRepository.updateDossier(updated);

                if (!mounted) return;

                if (rows > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dossier enregistré')),
                  );
                  Navigator.pop(context, updated);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur: aucun enregistrement effectué'),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
