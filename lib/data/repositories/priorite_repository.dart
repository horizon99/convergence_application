import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/database_helper.dart';
import '../../models/priorite.dart';

class PrioriteRepository {
  Future<List<Priorite>> getAllPriorites() async {
    final Database db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'priorite',
      orderBy: 'ID_Priorite',
    );

    return result.map((e) => Priorite.fromMap(e)).toList();
  }
}
