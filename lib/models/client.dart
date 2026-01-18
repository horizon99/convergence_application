class Client {
  final int id;
  final String nom;
  final String email;

  Client({
    required this.id,
    required this.nom,
    required this.email,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
    );
  }
}
