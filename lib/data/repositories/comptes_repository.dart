import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/compte_model.dart';

class ComptesRepository {
  Future<List<Compte>> getAllComptes() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      orderBy: 'ordre ASC, numero ASC',
    );

    return result.map((e) => Compte.fromMap(e)).toList();
  }

  Future<Compte?> getCompteById(int id) async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      where: 'id_compte = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) return Compte.fromMap(result.first);
    return null;
  }

  Future<int> insertCompte(Compte compte) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('comptes', compte.toMap());
  }

  Future<int> updateCompte(Compte compte) async {
    final db = await DatabaseHelper.instance.database;
    final map = Map<String, dynamic>.from(compte.toMap());
    map.remove('id_compte');

    return await db.update(
      'comptes',
      map,
      where: 'id_compte = ?',
      whereArgs: [compte.idCompte],
    );
  }

  Future<int> deleteCompte(int idCompte) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'comptes',
      where: 'id_compte = ?',
      whereArgs: [idCompte],
    );
  }

  Future<List<Compte>> getComptesByCategorie(String categorie) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      where: 'categorie = ?',
      whereArgs: [categorie],
      orderBy: 'ordre ASC, numero ASC',
    );

    return result.map((e) => Compte.fromMap(e)).toList();
  }

  Future<List<Compte>> getActifs() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      where: 'actif = 1',
      orderBy: 'ordre ASC, numero ASC',
    );

    return result.map((e) => Compte.fromMap(e)).toList();
  }

  Future<List<Compte>> getAllComptesActifsPassifs() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      orderBy: 'ordre ASC, numero ASC',
      where: 'categorie IN (?, ?)',
      whereArgs: ['actif', 'passif'],
    );

    return result.map((e) => Compte.fromMap(e)).toList();
  }

  Future<List<Compte>> getAllComptesChargesProduits() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'comptes',
      orderBy: 'ordre ASC, numero ASC',
      where: 'categorie IN (?, ?)',
      whereArgs: ['charge', 'produit'],
    );

    return result.map((e) => Compte.fromMap(e)).toList();
  }


}
