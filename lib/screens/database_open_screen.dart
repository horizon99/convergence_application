import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_helper.dart';
import 'dossiers_list_screen.dart';

class DatabaseOpenScreen extends StatefulWidget {
  const DatabaseOpenScreen({super.key});

  @override
  State<DatabaseOpenScreen> createState() => _DatabaseOpenScreenState();
}

class _DatabaseOpenScreenState extends State<DatabaseOpenScreen> {
  static const String _lastDatabasePathKey = 'last_database_path';

  bool _isOpening = false;
  String? _error;
  String? _lastDatabasePath;

  @override
  void initState() {
    super.initState();
    _loadLastDatabasePath();
  }

  Future<void> _loadLastDatabasePath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_lastDatabasePathKey);
    if (!mounted) return;

    setState(() {
      _lastDatabasePath = path;
    });
  }

  Future<void> _openDatabaseFromPath(String path) async {
    setState(() {
      _isOpening = true;
      _error = null;
    });

    try {
      await DatabaseHelper.instance.openDatabaseFile(path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDatabasePathKey, path);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DossiersListScreen()),
      );
    } catch (e) {
      setState(() {
        _error = 'Impossible d\'ouvrir le fichier: $e';
        _isOpening = false;
      });
    }
  }

  Future<void> _openDatabase() async {
    setState(() {
      _isOpening = true;
      _error = null;
    });

    try {
      final FilePickerResult? result;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
        // Sur macOS, le mode custom peut ne pas ouvrir le panneau selon la config native.
        // On filtre ensuite l'extension manuellement.
        result = await FilePicker.pickFiles(
          type: FileType.any,
          withData: false,
        );
      } else {
        result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['sqlite', 'db'],
          withData: false,
          lockParentWindow: true,
        );
      }

      final path = result?.files.single.path;
      if (path == null) {
        setState(() => _isOpening = false);
        return;
      }

      if (!_isSupportedDatabasePath(path)) {
        setState(() {
          _error = 'Veuillez selectionner un fichier .sqlite ou .db';
          _isOpening = false;
        });
        return;
      }

      await _openDatabaseFromPath(path);
    } catch (e) {
      setState(() {
        _error = 'Impossible d\'ouvrir le fichier: $e';
        _isOpening = false;
      });
    }
  }

  bool _isSupportedDatabasePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.sqlite') || lower.endsWith('.db');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storage_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenue dans Convergence',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'L\'application démarre sans données intégrées.\n'
                    'Sélectionnez votre fichier de données (par exemple dans Documents).',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isOpening ? null : _openDatabase,
                      icon: const Icon(Icons.folder_open),
                      label: Text(_isOpening ? 'Ouverture...' : 'Choisir un fichier de données'),
                    ),
                  ),
                  if (_lastDatabasePath != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isOpening
                            ? null
                            : () => _openDatabaseFromPath(_lastDatabasePath!),
                        icon: const Icon(Icons.history),
                        label: Text(
                          _lastDatabasePath!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
