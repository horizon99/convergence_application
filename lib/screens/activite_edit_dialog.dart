import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/activites_model.dart';
import '../../data/repositories/activites_repository.dart';

class EditActiviteDialog extends StatefulWidget {
  final Activite activite;

  const EditActiviteDialog({
    super.key,
    required this.activite,
  });

  @override
  State<EditActiviteDialog> createState() => _EditActiviteDialogState();
}

class _EditActiviteDialogState extends State<EditActiviteDialog> {
  late Activite _edit;

  final _libelleCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();
  final _fraisCtrl = TextEditingController();
  final _tarifCrtl = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// clone simple
    _edit = widget.activite.copyWith();

    _libelleCtrl.text = _edit.libelle;
    _tarifCrtl.text = _edit.tarif;
    _minutesCtrl.text = _edit.minutes?.toStringAsFixed(0) ?? '';
    _fraisCtrl.text = _edit.frais?.toStringAsFixed(2) ?? '';
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _minutesCtrl.dispose();
    _fraisCtrl.dispose();
    _tarifCrtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _edit.dateOp,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _edit = _edit.copyWith(dateOp: picked));
    }
  }

  Future<void> _save() async {
    _edit = _edit.copyWith(
      libelle: _libelleCtrl.text,
      tarif: _tarifCrtl.text,
      minutes: int.tryParse(_minutesCtrl.text),
      frais: double.tryParse(_fraisCtrl.text),
    );

    await ActivitesRepository().updateActivite(_edit);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier activité'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// DATE
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(
                  DateFormat('dd.MM.yyyy').format(_edit.dateOp),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// LIBELLÉ
            TextField(
              controller: _libelleCtrl,
              decoration: const InputDecoration(labelText: 'Libellé'),
            ),

            const SizedBox(height: 8),

            /// TARIF
            TextField(
              controller: _tarifCrtl,
              decoration: const InputDecoration(labelText: 'Tarif'),
            ),

            const SizedBox(height: 8),

            /// MINUTES
            TextField(
              controller: _minutesCtrl,
              decoration: const InputDecoration(labelText: 'Minutes'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 8),

            /// FRAIS
            TextField(
              controller: _fraisCtrl,
              decoration: const InputDecoration(labelText: 'Frais'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}