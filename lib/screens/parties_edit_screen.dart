import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../data/repositories/partie_repository.dart';
import '../models/partie_model.dart';
import '../data/repositories/contacts_repository.dart';
import '../models/contacts_model.dart';
import 'contact_edit_dialog.dart';
import '../app_helper.dart';

class PartieEditScreen extends StatefulWidget {
  final int dossierId;
  final int? idPartie; // Nullable to allow for new parties

  const PartieEditScreen({super.key, required this.dossierId, this.idPartie});
  bool get isEdit => idPartie != null;

  @override
  State<PartieEditScreen> createState() => _PartieEditScreenState();
}

class _PartieEditScreenState extends State<PartieEditScreen> {
  final PartieRepository _repository = PartieRepository();
  late Future<Partie> _partieFuture;
  late Future<List<Contact>> _contactsFuture;

  final _formKey = GlobalKey<FormState>();

  int? _selectedContactId;
  String? _selectedRole;
  bool _initialized = false;

  // Controllers
  final TextEditingController _attentionCtrl = TextEditingController();
  final TextEditingController _concerneCtrl = TextEditingController();
  final TextEditingController _facturableCtrl = TextEditingController();
  final List<String> _roles = AppHelper.rolesParties;

  @override
  void initState() {
    super.initState();
    _contactsFuture = ContactsRepository().getAllContacts();
    if (widget.isEdit) {
      _partieFuture = _repository.getPartieById(widget.idPartie!);
    } else {
      // If creating a new party, initialize with default values
      _partieFuture = Future.value(
        Partie(
          dossierId: widget.dossierId,
          contactId: 0,
          role: null,
          attention: '',
          concerne: '',
          participation: 0,
        ),
      );
    }
  }

  void _initControllers(Partie p) {
    if (_initialized) return;
    _initialized = true;
    _selectedContactId = p.contactId;
    _selectedRole = p.role;
    _attentionCtrl.text = p.attention ?? '';
    _concerneCtrl.text = p.concerne ?? '';
    _facturableCtrl.text = p.participation.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Éditer un intervenant' : 'Ajouter un intervenant',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: FutureBuilder<Partie>(
        future: _partieFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.isEdit) {
            final partie = snapshot.data!;
            _initControllers(partie);
          } else {
            // For new party, initialize controllers with default values
            _initControllers(
              Partie(
                dossierId: widget.dossierId,
                contactId: 0,
                role: null,
                attention: '',
                concerne: '',
                participation: 0,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ───────────── Contact (dropdown)
                  FutureBuilder<List<Contact>>(
                    future: _contactsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final contacts = snapshot.data!;

                      return Row(
                        children: [
                          Expanded(
                            child: DropdownSearch<Contact>(
                              items: (filter, loadProps) async => contacts,
                              selectedItem: contacts.firstWhere(
                                (c) => c.id == _selectedContactId,
                                orElse: () => contacts.first,
                              ),
                              itemAsString: (c) => c.nomPrenom,
                              compareFn: (a, b) =>
                                  a.id ==
                                  b.id, // <-- Ajouté pour la comparaison
                              popupProps: const PopupProps.dialog(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    labelText: 'Rechercher un contact',
                                  ),
                                ),
                              ),
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Contact',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              onSelected: (contact) {
                                setState(() {
                                  _selectedContactId = contact?.id;
                                });
                              },
                              validator: (contact) => contact == null
                                  ? 'Veuillez sélectionner un contact'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Action d'édition
                              if (_selectedContactId != null) {
                                _openContactEditor(
                                  contactId: _selectedContactId,
                                );
                              }
                            },
                            tooltip: 'Éditer',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _openContactEditor(),
                            tooltip: 'Ajouter',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedRole != null && _roles.contains(_selectedRole)
                        ? _selectedRole
                        : null,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: _roles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez sélectionner un rôle'
                        : null,
                  ),

                  TextFormField(
                    controller: _attentionCtrl,
                    decoration: const InputDecoration(labelText: 'Attention'),
                  ),

                  TextFormField(
                    controller: _concerneCtrl,
                    decoration: const InputDecoration(labelText: 'Concerne'),
                    maxLines: 2,
                  ),

                  TextFormField(
                    controller: _facturableCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Part facturable %',
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          try {
                            if (widget.isEdit) {
                              final partie = snapshot.data!;
                              final updatedPartie = partie.copyWith(
                                contactId: _selectedContactId,
                                role: _selectedRole,
                                attention: _attentionCtrl.text,
                                concerne: _concerneCtrl.text,
                                participation: _facturableCtrl.text.isNotEmpty
                                    ? int.tryParse(_facturableCtrl.text)
                                    : null,
                              );
                              await _repository.updatePartie(updatedPartie);
                              Navigator.pop(context, true);
                            } else {
                              final newPartie = Partie(
                                dossierId: widget.dossierId,
                                contactId: _selectedContactId!,
                                role: _selectedRole,
                                attention: _attentionCtrl.text,
                                concerne: _concerneCtrl.text,
                                participation: _facturableCtrl.text.isNotEmpty
                                    ? int.tryParse(_facturableCtrl.text)
                                    : null,
                              );
                              await _repository.insertPartie(newPartie);
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        },
                        child: Text(widget.isEdit ? 'Enregistrer' : 'Ajouter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openContactEditor({int? contactId}) async {
    final newContactId = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ContactEditScreen(
        contactId: contactId, // null = création
      ),
    );

    if (newContactId != null) {
      // Recharger les contacts
      setState(() {
        _contactsFuture = ContactsRepository().getAllContacts();
        // Sélectionner automatiquement le nouveau contact créé
        if (contactId == null) {
          _selectedContactId = newContactId;
        }
      });
    }
  }
}

