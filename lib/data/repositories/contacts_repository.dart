import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/contacts_model.dart';

class ContactsRepository {
  Future<List<Contact>> getAllContacts() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'contacts',
        orderBy: 'id_contact ASC',
      );

      return result.map((e) => Contact.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ContactsRepository.getAllContacts: $e\n$st');
      rethrow;
    }
  }

  Future <Contact?> getContactById(int id) async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'contacts',
        where: 'id_contact = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return Contact.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      //print('Exception in ContactsRepository.getContactById: $e\n$st');
      rethrow;
    }
  }

  Future<int> updateContact(Contact contact) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.update(
        'contacts',
        {
          'nom': contact.nom,
          'prenom': contact.prenom,
          'adresse': contact.adresse,
          'titre': contact.titre,
          'tel_fixe': contact.telFixe,
          'tel_mobile': contact.telMobile,
          'email': contact.email,
          'appel_lettre': contact.appelLettre,
          'fin_lettre': contact.finLettre,
          'remarques': contact.remarques,
          'adresse2': contact.adresse2,
          'no_rue': contact.noRue,
          'no_postal': contact.noPostal,
          'localite': contact.localite,
        },
        where: 'id_contact = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      //print('Exception in ContactsRepository.updateContact: $e\n$st');
      rethrow;
    }
  }
  Future<int> deleteContact(int idContact) async {
    try {
      final db = await DatabaseHelper.instance.database;

      return await db.delete(
        'contacts',
        where: 'id_contact = ?',
        whereArgs: [idContact],
      );
    } catch (e) {
      //print('Exception in ContactsRepository.deleteContact: $e\n$st');
      rethrow;
    }
  }
  
  Future<int> insertContact(Contact contact) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert(
        'contacts',
        contact.toMap(),
      );
    } catch (e) {
      //print('Exception in ContactsRepository.insertContact: $e\n$st');
      rethrow;
    }
  }
}
