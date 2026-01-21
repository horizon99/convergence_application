import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/contacts_model.dart';

class ContactsRepository {
  Future<List<Contact>> getAllContacts() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'contacts',
      orderBy: 'ID_Contact',
    );

    return result.map((e) => Contact.fromMap(e)).toList();
  }

  Future <Contact?> getContactById(int id) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'contacts',
      where: 'ID_Contact = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Contact.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateContact(Contact contact) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'contacts',
      {
        'Nom': contact.nom,
        'Prenom': contact.prenom,
        'Adresse': contact.adresse,
        'Titre': contact.titre,
        'Tel_fixe': contact.telFixe,
        'Tel_mobile': contact.telMobile,
        'Email': contact.email,
        'Appel_lettre': contact.appelLettre,
        'Fin_lettre': contact.finLettre,
        'Remarques': contact.remarques,
        'Adresse2': contact.adresse2,
        'NoRue': contact.noRue,
        'NoPostal': contact.noPostal,
        'Localite': contact.localite,
      },
      where: 'ID_Contact = ?',
      whereArgs: [contact.id],
    );
  }
  Future<int> deleteContact(int idContact) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'contacts',
      where: 'ID_Contact = ?',
      whereArgs: [idContact],
    );
  }
  
  Future<int> insertContact(Contact contact) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      'contacts',
      contact.toMap(),
    );

  }
}
