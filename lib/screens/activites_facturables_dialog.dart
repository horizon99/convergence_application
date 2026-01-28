import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/activites_facturables_model.dart';
import '../reports/activites_facturables_report.dart';

class ActivitesFacturablesDialog extends StatefulWidget {
  final List<ActiviteFacturable> activites;
  final DateTime dateDu;
  final DateTime dateAu;
  final String dossierLibelle;

  const ActivitesFacturablesDialog({
    super.key,
    required this.activites,
    required this.dateDu,
    required this.dateAu,
    required this.dossierLibelle,
  });

  @override
  State<ActivitesFacturablesDialog> createState() =>
      _ActivitesFacturablesDialogState();
}

class _ActivitesFacturablesDialogState
    extends State<ActivitesFacturablesDialog> {
  bool _afficherFrais = true;
  bool _afficherMontants = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options du rapport'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Afficher les frais'),
            value: _afficherFrais,
            onChanged: (value) {
              setState(() => _afficherFrais = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('Afficher les montants'),
            value: _afficherMontants,
            onChanged: (value) {
              setState(() => _afficherMontants = value ?? true);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Générer PDF'),
          onPressed: () async {
            Navigator.of(context).pop();

            final report = ActivitesFacturablesReport();
            final pdf = await report.buildReleveActivitesPdf(
              activites: widget.activites,
              dateDu: widget.dateDu,
              dateAu: widget.dateAu,
              dossierLibelle: widget.dossierLibelle,
              afficherFrais: _afficherFrais,
              afficherMontants: _afficherMontants,
            );

            final pdfBytes = await pdf.save();

            final directory = await getApplicationDocumentsDirectory();
            final fileName =
                'Releve_activites_${widget.dossierLibelle}_${DateTime.now().millisecondsSinceEpoch}.pdf';

            final file = File('${directory.path}/$fileName');
            await file.writeAsBytes(pdfBytes);

            // Ouverture automatique du PDF
            await OpenFilex.open(file.path);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF généré : ${file.path}')),
              );
            }
          },
        ),
      ],
    );
  }
}