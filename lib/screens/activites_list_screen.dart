import 'package:convergence_application/screens/activites_facturables_dialog.dart';
import 'package:convergence_application/screens/facture_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repositories/activites_repository.dart';
import '../data/repositories/activites_facturables_repository.dart';
import '../models/activites_facturables_model.dart';
import '../models/activites_model.dart';
import 'activite_edit_dialog.dart';

class ListActivitesScreen extends StatefulWidget {
  final int dossierId;
  final String dossierLibelleClient;

  const ListActivitesScreen({super.key, required this.dossierId, required this.dossierLibelleClient});

  @override
  State<ListActivitesScreen> createState() => _ListActivitesScreenState();
}

class _ListActivitesScreenState extends State<ListActivitesScreen> {
  late Future<List<ActiviteFacturable>> _activitesFuture;

  DateTime _dateDu = DateTime.now();
  DateTime _dateAu = DateTime.now();
  String _dossierLibelleClient = '';
  
  @override
  void initState() {
    super.initState();
    _activitesFuture = ActivitesFacturablesRepository().getActivitesFacturables(
      widget.dossierId,
    );
    _initDatesAndLoad();
    _dossierLibelleClient = widget.dossierLibelleClient; 
  }

  Future<void> _initDatesAndLoad() async {
    final minDate = await ActivitesRepository().getMinDateByDossier(
      widget.dossierId,
    );

    setState(() {
      _dateDu = minDate ?? DateTime.now();
      _activitesFuture = ActivitesFacturablesRepository()
          .getActivitesFacturables(widget.dossierId);
    });
  }

  Future<void> _filtrer() async {
    setState(() {
      _activitesFuture = ActivitesFacturablesRepository()
          .getActivitesFacturables(
            widget.dossierId,
            dateDu: _dateDu,
            dateAu: _dateAu,
          );
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

  Future<void> _confirmDelete(Activite activite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l’activité'),
        content: const Text(
          'Es-tu sûr de vouloir supprimer cette activité ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ActivitesRepository().deleteActivite(activite.idActivite!);
      _filtrer(); // recharge la liste filtrée
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_dossierLibelleClient: liste des activités'),
        backgroundColor: Colors.blue[50],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                /// DATE DU
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(
                      initial: _dateDu,
                      onPicked: (d) => setState(() => _dateDu = d),
                    ),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date du'),
                      child: Text(DateFormat('dd.MM.yyyy').format(_dateDu)),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// DATE AU
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(
                      initial: _dateAu,
                      onPicked: (d) => setState(() => _dateAu = d),
                    ),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date au'),
                      child: Text(DateFormat('dd.MM.yyyy').format(_dateAu)),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// FILTRER
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filtrer'),
                  onPressed: _filtrer,
                ),
              ],
            ),
          ),
        ),
      ),

      /// LISTE DES ACTIVITÉS
      body: FutureBuilder<List<ActiviteFacturable>>(
        future: _activitesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final activites = snapshot.data!;

          final totalMinutes = activites.fold<double>(
            0,
            (sum, a) => sum + (a.activite.minutes ?? 0),
          );
          final totalFrais = activites.fold<double>(
            0,
            (sum, a) => sum + (a.activite.frais ?? 0),
          );
          final totalMontant = activites.fold<double>(
            0,
            (sum, a) => sum + a.montantFacturable,
          );

          if (activites.isEmpty) {
            return const Center(child: Text('Aucune activité'));
          }

          return Container(
            color: Colors.yellow[50],
            child: Column(
              children: [
                /// EN-TÊTE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      _headerCell('Date', flex: 2),
                      _headerCell('Tarif', flex: 1),
                      _headerCell('Libellé', flex: 4),
                      _headerCell('Min.', flex: 1, align: TextAlign.right),
                      _headerCell('CHF/h', flex: 1, align: TextAlign.right),
                      _headerCell('Frais', flex: 1, align: TextAlign.right),
                      _headerCell(
                        'Montant   Suppr.',
                        flex: 2,
                        align: TextAlign.right,
                      ),
                      //_headerCell('1', flex: 1, align: TextAlign.right),
                    ],
                  ),
                ),

                const Divider(height: 1),

                /// LISTE
                Expanded(
                  child: ListView.separated(
                    itemCount: activites.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = activites[index];

                      return InkWell(
                        onTap: () async {
                          final updated = await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                EditActiviteDialog(activite: a.activite),
                          );

                          if (updated == true) {
                            _filtrer(); // recharge la liste
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          child: Row(
                            children: [
                              _cell(
                                DateFormat(
                                  'dd.MM.yyyy',
                                ).format(a.activite.dateOp),
                                flex: 2,
                              ),
                              _cell(a.activite.tarif.toString(), flex: 1),
                              _cell(a.activite.libelle, flex: 4),
                              _cell(
                                a.activite.minutes?.toStringAsFixed(0) ?? '',
                                flex: 1,
                                align: TextAlign.right,
                              ),
                              _cell(
                                a.tarifHoraire.toStringAsFixed(0),
                                flex: 1,
                                align: TextAlign.right,
                              ),
                              _cell(
                                a.activite.frais?.toStringAsFixed(2) ?? '',
                                flex: 1,
                                align: TextAlign.right,
                              ),
                              _cell(
                                a.montantFacturable.toStringAsFixed(2),
                                flex: 2,
                                align: TextAlign.right,
                              ),

                              /// BOUTON SUPPRIMER
                              SizedBox(
                                width: 36,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red[400],
                                  tooltip: 'Supprimer',
                                  onPressed: () => _confirmDelete(a.activite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// TOTAUX
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: const Border(
                      top: BorderSide(color: Colors.black26),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _cell(
                        'Totaux',
                        flex: 7,
                        align: TextAlign.right,
                        weight: FontWeight.bold,
                      ),
                      _cell(
                        totalMinutes.toStringAsFixed(0),
                        flex: 1,
                        align: TextAlign.right,
                        weight: FontWeight.bold,
                      ),
                      const Spacer(flex: 1), // colonne tarif horaire
                      _cell(
                        totalFrais.toStringAsFixed(2),
                        flex: 1,
                        align: TextAlign.right,
                        weight: FontWeight.bold,
                      ),
                      _cell(
                        totalMontant.toStringAsFixed(2),
                        flex: 2,
                        align: TextAlign.right,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      /// BOTTOM BAR
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacturePrepare(
                        dossierId: widget.dossierId,
                        dateDu: _dateDu,
                        dateAu: _dateAu,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt),
                label: const Text('Facture'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final data = await _activitesFuture;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ActivitesFacturablesDialog(
                        activites: data,
                        dateDu: _dateDu,
                        dateAu: _dateAu,
                        dossierLibelle: _dossierLibelleClient,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('Relevé'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    FontWeight weight = FontWeight.normal,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: weight),
      ),
    );
  }

  Widget _headerCell(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
