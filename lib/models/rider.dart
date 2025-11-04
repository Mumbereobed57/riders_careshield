class Rider {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role; // Always "rider"
  final String vehicleType; // "Boda" or "My Car"
  final String licenseNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rider({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.vehicleType,
    required this.licenseNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      vehicleType: json['vehicleType'] as String,
      licenseNumber: json['licenseNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }
}
