class Priorite {
  final int id;
  final String label;

  Priorite({
    required this.id,
    required this.label,
  });

  factory Priorite.fromMap(Map<String, dynamic> map) {
    return Priorite(
      id: map['id_priorite'],
      label: map['priorite_text'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id_priorite': id,
      'priorite_text': label,
    };
  }
}
