import 'package:flutter/material.dart';
import '../data/repositories/client_repository.dart';
import '../models/client.dart';

class ClientsScreen extends StatelessWidget {
  ClientsScreen({super.key});
  final ClientRepository repository = ClientRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: FutureBuilder<List<Client>>(
        future: repository.getAllClients(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data!;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                title: Text(client.nom),
                subtitle: Text(client.email),
              );
            },
          );
        },
      ),
    );
  }
}
