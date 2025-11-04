class Customer {
  final String id;
  final String fullName;
  final String phone;

  Customer({
    required this.id,
    required this.fullName,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
    };
  }

  /// Returns abbreviated name for privacy (e.g., "John Doe" -> "John D.")
  String get abbreviatedName {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0]} ${names[1][0]}.';
    }
    return fullName;
  }
}
