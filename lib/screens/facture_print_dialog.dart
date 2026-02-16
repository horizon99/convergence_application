import 'package:flutter/material.dart';

class FacturePrintResult {
  final bool generated;
  final bool afficherFacture;
  final bool afficherReleveActivites;
  final bool afficherFrais;
  final bool afficherMontants;
  final bool afficherQrCode;

  FacturePrintResult({
    required this.generated,
    required this.afficherFacture,
    required this.afficherReleveActivites,
    required this.afficherFrais,
    required this.afficherMontants,
    required this.afficherQrCode,
  });
}

class FacturePrintDialog extends StatefulWidget {
  //final List<ActiviteFacturable> activites;
  
  const FacturePrintDialog({
    super.key,
    //required this.activites,
    });

  @override
  State<FacturePrintDialog> createState() => _FacturePrintDialogState();
}

class _FacturePrintDialogState extends State<FacturePrintDialog> {
  bool _afficherFacture = true;
  bool _afficherReleveActivites = true;
  bool _afficherFrais = false;
  bool _afficherMontants = false;
  bool _afficherQrCode = true;
  //bool _preparerEmail = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options de génération de PDF'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Afficher la facture'),
            value: _afficherFacture,
            onChanged: (value) {
              setState(() {
                _afficherFacture = value ?? true;
                if (!_afficherFacture) {
                  _afficherQrCode = false;
                } else {
                  _afficherQrCode = true;
                }
              });
            },
          ),
          CheckboxListTile(
            title: const Text('   Afficher le QR code'),
            value: _afficherQrCode,
            contentPadding: const EdgeInsets.only(left: 16.0),
            onChanged: _afficherFacture
                ? (value) {
                    setState(() => _afficherQrCode = value ?? true);
                  }
                : null,
          ),
          const Divider(),
          CheckboxListTile(
            title: const Text('Afficher le relevé d\'activités'),
            value: _afficherReleveActivites,
            onChanged: (value) {
              setState(() => _afficherReleveActivites = value ?? true);
              if (!_afficherReleveActivites) {
                _afficherFrais = false;
                _afficherMontants = false;
              }
            },
          ),
          CheckboxListTile(
            title: const Text('   Afficher les frais'),
            value: _afficherFrais,
            contentPadding: const EdgeInsets.only(left: 16.0),
            onChanged: _afficherReleveActivites
                ? (value) {
                    setState(() => _afficherFrais = value ?? true);
                  }
                : null,
          ),
          CheckboxListTile(
            title: const Text('   Afficher les montants'),
            value: _afficherMontants,
            contentPadding: const EdgeInsets.only(left: 16.0),
            onChanged: _afficherReleveActivites
                ? (value) {
                    setState(() => _afficherMontants = value ?? true);
                  }
                : null,
          ),
          //const Divider(),
          //CheckboxListTile(
          //  title: const Text('Préparer le courriel'),
          //  value: _preparerEmail,
          //  onChanged: (value) {
          //    setState(() {
          //      _preparerEmail = value ?? false;
          //    });
          //  },
          //),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(FacturePrintResult(
            generated: false,
            afficherFacture: _afficherFacture,
            afficherReleveActivites: _afficherReleveActivites,
            afficherFrais: _afficherFrais,
            afficherMontants: _afficherMontants,
            afficherQrCode: _afficherQrCode,
          )),
        ),
        TextButton(
          child: const Text('Générer PDF'),
          onPressed: () async {
            Navigator.of(context).pop(FacturePrintResult(
              generated: true,
              afficherFacture: _afficherFacture,
              afficherReleveActivites: _afficherReleveActivites,
              afficherFrais: _afficherFrais,
              afficherMontants: _afficherMontants,
              afficherQrCode: _afficherQrCode,
            ));

            // Give the UI a short moment to finish closing the dialog.
          }
        ),
      ],
    );
  }
}
