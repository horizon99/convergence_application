import 'package:flutter/material.dart';
import '../data/repositories/contacts_repository.dart';
import '../models/contacts_model.dart';
import '../app_helper.dart';
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
                  Row(
                    children: [
                      const Icon(Icons.person, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: _selectedTitre ?? '',
                          ),
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
                                    filled: true,
                                    fillColor: Color(0xFFFFFDE7),
                                  ),
                                  onChanged: (value) {
                                    // 👉 accepte le texte libre
                                    _selectedTitre = value;
                                  },
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _nomCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nom *',
                            filled: true,
                            fillColor: Color(0xFFFFFDE7),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Le nom est obligatoire'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _prenomCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            filled: true,
                            fillColor: Color(0xFFFFFDE7),
                          ),
                        ),
                      ),
                    ],
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
                            filled: true,
                            fillColor: Color.fromARGB(255, 205, 242, 252),
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
                            filled: true,
                            fillColor: Color.fromARGB(255, 205, 242, 252),
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Color.fromARGB(255, 205, 242, 252),
                    ),
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
                          decoration: const InputDecoration(
                            labelText: 'Rue',
                            filled: true,
                            fillColor: Color.fromARGB(255, 193, 241, 225),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _noRueCtrl,
                          decoration: const InputDecoration(
                            labelText: 'N°',
                            filled: true,
                            fillColor: Color.fromARGB(255, 193, 241, 225),
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: _adresse2Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Complément d’adresse',
                      filled: true,
                      fillColor: Color.fromARGB(255, 193, 241, 225),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _noPostalCtrl,
                          decoration: const InputDecoration(
                            labelText: 'NPA',
                            filled: true,
                            fillColor: Color.fromARGB(255, 193, 241, 225),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _localiteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Localité',
                            filled: true,
                            fillColor: Color.fromARGB(255, 193, 241, 225),
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
                                    filled: true,
                                    fillColor: Color(0xFFFFFDE7),
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
                                    filled: true,
                                    fillColor: Color(0xFFFFFDE7),
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
                    decoration: const InputDecoration(
                      labelText: 'Remarques',
                      filled: true,
                      fillColor: Color(0xFFFFFDE7),
                    ),
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
