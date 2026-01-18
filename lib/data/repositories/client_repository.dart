import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../../models/client.dart';

class ClientRepository {
  Future<List<Client>> getAllClients() async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query('clients', orderBy: 'nom');

    return maps.map((e) => Client.fromMap(e)).toList();
  }
}
