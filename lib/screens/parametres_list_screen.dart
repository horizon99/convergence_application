import 'package:flutter/material.dart';

import '../data/database/database_helper.dart';
import 'database_open_screen.dart';
import 'mediateur_edit_screen.dart';
import 'tarif_edit_screen.dart';
import 'comptes_list_screen.dart';

class ParametresListScreen extends StatelessWidget {
  const ParametresListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const MediateurEditScreen()),
              );

              if (changed == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Médiateur mis à jour')),
                );
              }
            },
            icon: const Icon(Icons.person),
            label: const Text('Médiateur'),
          ),

          // Placeholders for other settings buttons
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TarifEditScreen()),
              );
            },
            icon: const Icon(Icons.price_check),
            label: const Text('Tarifs'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComptesListScreen()),
              );
            },
            icon: const Icon(Icons.account_balance),
            label: const Text('Comptes'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Autre paramètre (non implémenté)')),
              );
            },
            icon: const Icon(Icons.tune),
            label: const Text('Autres paramètres'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await DatabaseHelper.instance.closeDatabase();
              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DatabaseOpenScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Ouvrir une autre base SQLite'),
          ),
        ],
      ),
    );
  }
}
