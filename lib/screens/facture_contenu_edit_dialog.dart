import 'package:flutter/material.dart';

class FactureContenuEditDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const FactureContenuEditDialog({super.key, required this.initialData});

  @override
  State<FactureContenuEditDialog> createState() => _FactureContenuEditDialogState();
}

class _FactureContenuEditDialogState extends State<FactureContenuEditDialog> {
  late TextEditingController _texteFactureController;
  late TextEditingController _honorairesController;
  late TextEditingController _fraisController;
  late TextEditingController _minutesController;
  late TextEditingController _montantTarifController;

  @override
  void initState() {
    super.initState();
    _texteFactureController = TextEditingController(text: widget.initialData['texteFacture'] ?? '');
    _honorairesController = TextEditingController(text: (widget.initialData['totalHonoraires'] ?? '').toString());
    _fraisController = TextEditingController(text: (widget.initialData['totalFrais'] ?? '').toString());
    _minutesController = TextEditingController(text: (widget.initialData['totalMinutes'] ?? '').toString());
    _montantTarifController = TextEditingController(text: (widget.initialData['montantTarif'] ?? '').toString());
  }

  @override
  void dispose() {
    _texteFactureController.dispose();
    _honorairesController.dispose();
    _fraisController.dispose();
    _minutesController.dispose();
    _montantTarifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Éditer la ligne'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _texteFactureController,
              decoration: const InputDecoration(labelText: 'Texte Facture'),
            ),
            TextFormField(
              controller: _montantTarifController,
              decoration: const InputDecoration(labelText: 'Tarif horaire'),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                final tarif = double.tryParse(value) ?? 0;
                final honoraires = (tarif / 60) * (int.tryParse(_minutesController.text) ?? 0);
                _honorairesController.text = honoraires.toStringAsFixed(2);
              }),
            ),
            TextFormField(
              controller: _minutesController,
              decoration: const InputDecoration(labelText: 'Minutes'),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                final minutes = int.tryParse(value) ?? 0;
                final honoraires = (minutes / 60) * (double.tryParse(_montantTarifController.text) ?? 0);
                _honorairesController.text = honoraires.toStringAsFixed(2);
              }),
            ),
            TextFormField(
              controller: _honorairesController,
              decoration: const InputDecoration(labelText: 'Honoraires'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _fraisController,
              decoration: const InputDecoration(labelText: 'Frais'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'texteFacture': _texteFactureController.text,
              'totalHonoraires': double.tryParse(_honorairesController.text) ?? 0.0,
              'totalFrais': double.tryParse(_fraisController.text) ?? 0.0,
              'totalMinutes': int.tryParse(_minutesController.text) ?? 0,
              'montantTarif': double.tryParse(_montantTarifController.text) ?? 0.0,
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
