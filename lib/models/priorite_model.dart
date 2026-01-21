class Priorite {
  final int id;
  final String label;

  Priorite({
    required this.id,
    required this.label,
  });

  factory Priorite.fromMap(Map<String, dynamic> map) {
    return Priorite(
      id: map['ID_Priorite'],
      label: map['lblPriorite'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'ID_Priorite': id,
      'lblPriorite': label,
    };
  }
}
