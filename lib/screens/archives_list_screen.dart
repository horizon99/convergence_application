import 'package:flutter/material.dart';

import '../data/repositories/dossier_repository.dart';
import '../models/dossier_model.dart';
import 'dossier_detail_screen.dart';

class ArchivesListScreen extends StatefulWidget {
  const ArchivesListScreen({super.key});

  @override
  State<ArchivesListScreen> createState() => _ArchivesListScreenState();
}

class _ArchivesListScreenState extends State<ArchivesListScreen> {
  late Future<List<Dossier>> _archivesFuture;
  List<Dossier> _archives = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  void _loadArchives() {
    _archivesFuture = getDossiersArchives();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      int modifier = ascending ? 1 : -1;

      switch (columnIndex) {
        case 1: // N° Archive
          _archives.sort((a, b) {
            final ai = a.noArchive ?? -1;
            final bi = b.noArchive ?? -1;
            return modifier * ai.compareTo(bi);
          });
          break;
        case 2: // N° Dossier (id)
          _archives.sort((a, b) {
            final ai = a.id ?? -1;
            final bi = b.id ?? -1;
            return modifier * ai.compareTo(bi);
          });
          break;
        case 3: // Date archive
          _archives.sort((a, b) {
            final ad = a.dateArchive ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bd = b.dateArchive ?? DateTime.fromMillisecondsSinceEpoch(0);
            return modifier * ad.compareTo(bd);
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossiers archivés'),
      ),
      body: FutureBuilder<List<Dossier>>(
        future: _archivesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final archives = snapshot.data ?? [];

          // initialize local list once when data arrives
          if (_archives.isEmpty) {
            _archives = List<Dossier>.from(archives);
          }

          if (_archives.isEmpty) {
            return const Center(child: Text('Aucune archive'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                const DataColumn(label: Text('')), // edit button
                DataColumn(
                  label: const Text('N° Archive'),
                  onSort: (ci, asc) => _onSort(ci, asc),
                ),
                DataColumn(
                  label: const Text('N° Dossier'),
                  onSort: (ci, asc) => _onSort(ci, asc),
                ),
                DataColumn(
                  label: const Text('Date archive'),
                  onSort: (ci, asc) => _onSort(ci, asc),
                ),
                const DataColumn(label: Text('Libellé')),
              ],
              rows: _archives.map((d) {
                return DataRow(cells: [
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Ouvrir',
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<Dossier>(
                        MaterialPageRoute(
                          builder: (_) => DossierDetailScreen(dossier: d),
                        ),
                      );

                      if (updated != null) {
                        setState(() {
                          _loadArchives();
                          _archives = []; // force reload from future
                        });
                      }
                    },
                  )),
                  DataCell(Text(d.noArchive?.toString() ?? '')), 
                  DataCell(Text(d.id?.toString() ?? '')), 
                  DataCell(Text(_formatDate(d.dateArchive))),
                  DataCell(Text(d.libelle)),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
