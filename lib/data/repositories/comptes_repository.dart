import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/compte_model.dart';

class ComptesRepository {
  Future<List<Compte>> getAllComptes() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        orderBy: 'ordre ASC, numero ASC',
      );

      return result.map((e) => Compte.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ComptesRepository.getAllComptes: $e\n$st');
      rethrow;
    }
  }

  Future<Compte?> getCompteById(int id) async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        where: 'id_compte = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) return Compte.fromMap(result.first);
      return null;
    } catch (e) {
      //print('Exception in ComptesRepository.getCompteById: $e\n$st');
      rethrow;
    }
  }

  Future<int> insertCompte(Compte compte) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('comptes', compte.toMap());
    } catch (e) {
      //print('Exception in ComptesRepository.insertCompte: $e\n$st');
      rethrow;
    }
  }

  Future<int> updateCompte(Compte compte) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final map = Map<String, dynamic>.from(compte.toMap());
      map.remove('id_compte');

      return await db.update(
        'comptes',
        map,
        where: 'id_compte = ?',
        whereArgs: [compte.idCompte],
      );
    } catch (e) {
      //print('Exception in ComptesRepository.updateCompte: $e\n$st');
      rethrow;
    }
  }

  Future<int> deleteCompte(int idCompte) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete(
        'comptes',
        where: 'id_compte = ?',
        whereArgs: [idCompte],
      );
    } catch (e) {
      //print('Exception in ComptesRepository.deleteCompte: $e\n$st');
      rethrow;
    }
  }

  Future<List<Compte>> getComptesByCategorie(String categorie) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        where: 'categorie = ?',
        whereArgs: [categorie],
        orderBy: 'ordre ASC, numero ASC',
      );

      return result.map((e) => Compte.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ComptesRepository.getComptesByCategorie: $e\n$st');
      rethrow;
    }
  }

  Future<List<Compte>> getActifs() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        where: 'actif = 1',
        orderBy: 'ordre ASC, numero ASC',
      );

      return result.map((e) => Compte.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ComptesRepository.getActifs: $e\n$st');
      rethrow;
    }
  }

  Future<List<Compte>> getAllComptesActifsPassifs() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        orderBy: 'ordre ASC, numero ASC',
        where: 'categorie IN (?, ?)',
        whereArgs: ['actif', 'passif'],
      );

      return result.map((e) => Compte.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ComptesRepository.getAllComptesActifsPassifs: $e\n$st');
      rethrow;
    }
  }

  Future<List<Compte>> getAllComptesChargesProduits() async {
    try {
      final Database db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'comptes',
        orderBy: 'ordre ASC, numero ASC',
        where: 'categorie IN (?, ?)',
        whereArgs: ['charge', 'produit'],
      );

      return result.map((e) => Compte.fromMap(e)).toList();
    } catch (e) {
      //print('Exception in ComptesRepository.getAllComptesChargesProduits: $e\n$st');
      rethrow;
    }
  }


}
