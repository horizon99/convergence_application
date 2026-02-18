import 'package:flutter/material.dart';
import '../data/repositories/dossier_repository.dart';
import '../models/dossier_model.dart';
import 'dossier_detail_screen.dart';
import 'archives_list_screen.dart';
import 'parametres_list_screen.dart';
import 'ecritures_list_screen.dart';
import 'facture_list_screen.dart';

class DossiersListScreen extends StatefulWidget {
  const DossiersListScreen({super.key});

  @override
  State<DossiersListScreen> createState() => _DossiersListScreenState();
}

class _DossiersListScreenState extends State<DossiersListScreen> {
  final DossierRepository repository = DossierRepository();
  late Future<List<Dossier>> _dossiersFuture;

  @override
  void initState() {
    super.initState();
    _loadDossiers();
  }

  void _loadDossiers() {
    _dossiersFuture = repository.getAllDossiers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossiers en cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter',
            onPressed: () async {
              final newDossier = await Navigator.of(context).push<Dossier>(
                MaterialPageRoute(
                  builder: (_) => DossierDetailScreen(
                    dossier: Dossier(
                      id: 0,
                      libelle: '',
                      tva: null,
                      prioriteId: 0,
                      prioriteLabel: '',
                      afaire: null,
                      dateCreation: null,
                      dateArchive: null,
                      noArchive: null,
                      archive: false,
                      refTribunal: '',
                      libelleClient: null,
                      notes: null,
                      groupeTarif: null,
                    ),
                  ),
                ),
              );

              if (newDossier != null) {
                setState(() {
                  _loadDossiers();
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Dossier>>(
        future: _dossiersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final dossiers = snapshot.data ?? [];

          if (dossiers.isEmpty) {
            return const Center(child: Text('Aucun dossier'));
          }

          return ListView.builder(
            itemCount: dossiers.length,
            itemBuilder: (context, index) {
              final dossier = dossiers[index];

              return ListTile(
                leading: Chip(
                  avatar: Icon(
                    dossier.prioriteIcon,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    dossier.prioriteLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: dossier.prioriteColor,
                ),
                title: Text('${dossier.id} - ${dossier.libelle}'),
                subtitle: Text('A faire: ${dossier.afaire}'),
                onTap: () async {
                  final updatedDossier = await Navigator.of(context).push<Dossier>(
                    MaterialPageRoute(
                      builder: (_) => DossierDetailScreen(dossier: dossier),
                    ),
                  );

                  if (updatedDossier != null) {
                    setState(() {
                      _loadDossiers();
                    });
                  }
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FactureListScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Factures'),
              ),

              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EcritureesListScreen()),
                  );
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Comptabilité'),
              ),

              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArchivesListScreen()),
                  );
                },
                icon: const Icon(Icons.archive),
                label: const Text('Archives'),
              ),

              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ParametresListScreen()),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Paramètres'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
