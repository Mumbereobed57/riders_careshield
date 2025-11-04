class Drug {
  final String id;
  final String name;
  final String description;
  final String dosage;

  Drug({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
    };
  }
}
