import 'package:flutter/material.dart';

class FactureContenuEditDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const FactureContenuEditDialog({super.key, required this.initialData});

  @override
  State<FactureContenuEditDialog> createState() => _FactureContenuEditDialogState();
}

class _FactureContenuEditDialogState extends State<FactureContenuEditDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _honorairesController;
  late TextEditingController _fraisController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialData['descriptionTarif'] ?? '');
    _honorairesController = TextEditingController(text: (widget.initialData['totalHonoraires'] ?? '').toString());
    _fraisController = TextEditingController(text: (widget.initialData['totalFrais'] ?? '').toString());
    _minutesController = TextEditingController(text: (widget.initialData['totalMinutes'] ?? '').toString());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _honorairesController.dispose();
    _fraisController.dispose();
    _minutesController.dispose();
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
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
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
            TextFormField(
              controller: _minutesController,
              decoration: const InputDecoration(labelText: 'Minutes'),
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
              'descriptionTarif': _descriptionController.text,
              'totalHonoraires': double.tryParse(_honorairesController.text) ?? 0.0,
              'totalFrais': double.tryParse(_fraisController.text) ?? 0.0,
              'totalMinutes': int.tryParse(_minutesController.text) ?? 0,
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
