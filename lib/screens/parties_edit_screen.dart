import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../data/repositories/partie_repository.dart';
import '../models/partie_model.dart';
import '../data/repositories/contacts_repository.dart';
import '../models/contacts_model.dart';
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
          facturable: 0,
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
    _facturableCtrl.text = p.facturable.toString();
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
                facturable: 0,
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
                              onChanged: (contact) {
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
                                facturable: _facturableCtrl.text.isNotEmpty
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
                                facturable: _facturableCtrl.text.isNotEmpty
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

//------------------------------------------------------
//------------------------------------------------------ Contact Edit Screen
//------------------------------------------------------

class ContactEditScreen extends StatefulWidget {
  final int? contactId; // null = création

  const ContactEditScreen({super.key, this.contactId});

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  late Future<Contact?> _contactFuture;
  bool _initialized = false;

  final ContactsRepository _repository = ContactsRepository();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final List<String> _titreList = AppHelper.titreContact;
  String? _selectedTitre;
  final TextEditingController _telFixeCtrl = TextEditingController();
  final TextEditingController _telMobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _adresse2Ctrl = TextEditingController();
  final TextEditingController _noRueCtrl = TextEditingController();
  final TextEditingController _noPostalCtrl = TextEditingController();
  final TextEditingController _localiteCtrl = TextEditingController();
  //final TextEditingController _appelLettreCtrl = TextEditingController();
  //final TextEditingController _finLettreCtrl = TextEditingController();
  final List<String> _appelLettreList = AppHelper.appelLettreContact;
  String? _selectedAppelLettre;
  final List<String> _finLettreList = AppHelper.finLettreContact;
  String? _selectedFinLettre;
  final TextEditingController _remarquesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contactId == null) {
      _contactFuture = Future.value(Contact(id: null, nom: ''));
    } else {
      _contactFuture = ContactsRepository().getContactById(widget.contactId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contactId == null ? 'Ajouter un contact' : 'Éditer le contact',
        ),
      ),
      body: FutureBuilder<Contact?>(
        future: _contactFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contact = snapshot.data!;
          _initControllers(contact);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ───────────── Identité
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _selectedTitre ?? ''),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _titreList;
                      }
                      return _titreList.where(
                        (titre) => titre.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (selection) {
                      setState(() {
                        _selectedTitre = selection;
                      });
                    },
                    fieldViewBuilder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Titre',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // 👉 accepte le texte libre
                              _selectedTitre = value;
                            },
                          );
                        },
                  ),

                  TextFormField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Le nom est obligatoire'
                        : null,
                  ),

                  TextFormField(
                    controller: _prenomCtrl,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),

                  const SizedBox(height: 16),

                  /// ───────────── Coordonnées
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _telFixeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone fixe',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _telMobileCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone mobile',
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  /// ───────────── Adresse
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _adresseCtrl,
                          decoration: const InputDecoration(labelText: 'Rue'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _noRueCtrl,
                          decoration: const InputDecoration(labelText: 'N°'),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: _adresse2Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Complément d’adresse',
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _noPostalCtrl,
                          decoration: const InputDecoration(labelText: 'NPA'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _localiteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Localité',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ───────────── Correspondance
                  ///
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: _selectedAppelLettre ?? '',
                          ),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _appelLettreList;
                            }
                            return _appelLettreList.where(
                              (titre) => titre.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (selection) {
                            setState(() {
                              _selectedAppelLettre = selection;
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Appel de lettre',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    // 👉 accepte le texte libre
                                    _selectedAppelLettre = value;
                                  },
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: _selectedFinLettre ?? '',
                          ),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _finLettreList;
                            }
                            return _finLettreList.where(
                              (titre) => titre.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (selection) {
                            setState(() {
                              _selectedFinLettre = selection;
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Appel de lettre',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    // 👉 accepte le texte libre
                                    _selectedFinLettre = value;
                                  },
                                );
                              },
                        ),
                      ), // Pour aligner à droite
                    ],
                  ),

                  TextFormField(
                    controller: _remarquesCtrl,
                    decoration: const InputDecoration(labelText: 'Remarques'),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  /// ───────────── Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final updated = contact.copyWith(
                            nom: _nomCtrl.text,
                            prenom: _prenomCtrl.text,
                            titre: _selectedTitre,
                            telFixe: _telFixeCtrl.text,
                            telMobile: _telMobileCtrl.text,
                            email: _emailCtrl.text,
                            adresse: _adresseCtrl.text,
                            adresse2: _adresse2Ctrl.text,
                            noRue: _noRueCtrl.text,
                            noPostal: _noPostalCtrl.text,
                            localite: _localiteCtrl.text,
                            appelLettre: _selectedAppelLettre,
                            finLettre: _selectedFinLettre,
                            remarques: _remarquesCtrl.text,
                          );

                          int? savedContactId;
                          if (widget.contactId == null) {
                            savedContactId = await _repository.insertContact(
                              updated,
                            );
                          } else {
                            await _repository.updateContact(updated);
                            savedContactId = widget.contactId;
                          }

                          Navigator.pop(context, savedContactId);
                        },
                        child: const Text('Enregistrer'),
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

  void _initControllers(Contact c) {
    if (_initialized) return;
    _initialized = true;

    _nomCtrl.text = c.nom;
    _prenomCtrl.text = c.prenom ?? '';
    _selectedTitre = c.titre;
    _telFixeCtrl.text = c.telFixe ?? '';
    _telMobileCtrl.text = c.telMobile ?? '';
    _emailCtrl.text = c.email ?? '';
    _adresseCtrl.text = c.adresse ?? '';
    _adresse2Ctrl.text = c.adresse2 ?? '';
    _noRueCtrl.text = c.noRue ?? '';
    _noPostalCtrl.text = c.noPostal ?? '';
    _localiteCtrl.text = c.localite ?? '';
    _selectedAppelLettre = c.appelLettre ?? '';
    _selectedFinLettre = c.finLettre ?? '';
    _remarquesCtrl.text = c.remarques ?? '';
  }
}
