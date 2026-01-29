import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/mediateur_model.dart';
import '../database/database_helper.dart';

class MediateurRepository { 
  Future<List<Mediateur>> getAllMediateurs() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'mediateurs',
      orderBy: 'id_mediateur ASC',
    );

    return result.map((e) => Mediateur.fromMap(e)).toList();
  } 

  Future<Mediateur> getMediateur() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      'SELECT * FROM mediateur LIMIT 1',
    );
    final resultFirst = result.first;

    return Mediateur.fromMap(resultFirst);
  } 
}