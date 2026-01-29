import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/repositories/activites_repository.dart';
import '../data/repositories/tarifs_repository.dart';
import '../models/activites_model.dart';
import '../models/tarifs_model.dart';

class ActiviteSaisieCard extends StatefulWidget {
  final int dossierId;

  const ActiviteSaisieCard({super.key, required this.dossierId});

  @override
  State<ActiviteSaisieCard> createState() => _ActiviteSaisieCardState();
}

class _ActiviteSaisieCardState extends State<ActiviteSaisieCard> {
  final _formKey = GlobalKey<FormState>();

  final _libelleController = TextEditingController();
  final _minutesController = TextEditingController();
  final _fraisController = TextEditingController();

  DateTime _dateActivite = DateTime.now();
  String? _selectedTarif;

  late Future<List<ModeleTarif>> _tarifsFuture;

  @override
  void initState() {
    super.initState();
    _tarifsFuture = TarifsRepository().getAllTarifs();
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DATE
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateActivite,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('fr', 'CH'),
                    );
                    if (picked != null) {
                      setState(() => _dateActivite = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('dd.MM.yyyy').format(_dateActivite)),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// TARIF
              Expanded(
                flex: 2,
                child: FutureBuilder<List<ModeleTarif>>(
                  future: _tarifsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedTarif,
                      decoration: const InputDecoration(
                        labelText: 'Tarif',
                        border: OutlineInputBorder(),
                      ),
                      items: snapshot.data!
                          .map(
                            (tarif) => DropdownMenuItem<String>(
                              value: tarif.codeTarif,
                              child: Text(tarif.codeTarif),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedTarif = value);
                      },
                      validator: (value) =>
                          value == null ? 'Tarif requis' : null,
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              /// LIBELLÉ
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: _libelleController,
                  decoration: const InputDecoration(
                    labelText: 'Libellé',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Libellé requis' : null,
                ),
              ),

              const SizedBox(width: 8),

              /// MINUTES
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),

              const SizedBox(width: 8),

              /// FRAIS
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _fraisController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Frais',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+(\.\d{0,2})?$'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// BOUTON SAVE
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final activite = Activite(
                        idActivite: null,
                        dateActivite: _dateActivite,
                        libelle: _libelleController.text,
                        minutes: int.tryParse(_minutesController.text),
                        frais: double.tryParse(_fraisController.text),
                        dossierId: widget.dossierId,
                        codeTarif: _selectedTarif!,
                      );

                      await ActivitesRepository().insertActivite(activite);

                      // RESET FORM
                      _formKey.currentState!.reset();
                      _libelleController.clear();
                      _minutesController.clear();
                      _fraisController.clear();

                      setState(() {
                        _dateActivite = DateTime.now();
                        _selectedTarif = null;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Activité enregistrée'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l’enregistrement: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _minutesController.dispose();
    _fraisController.dispose();
    super.dispose();
  }
}
