import 'package:intl/intl.dart';
import 'customer.dart';
import 'drug.dart';
import 'pharmacy.dart';

class Order {
  final String id;
  final String stage;
  final String location;
  final String status; // "pending", "accepted", "delivered"
  final String eta;
  final double totalAmount;
  final double deliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer user;
  final Pharmacy? pharmacy;
  final List<Drug> drugs;
  final String? riderId;

  Order({
    required this.id,
    required this.stage,
    required this.location,
    required this.status,
    required this.eta,
    required this.totalAmount,
    required this.deliveryFee,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.pharmacy,
    required this.drugs,
    this.riderId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      stage: json['stage'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      eta: json['eta'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: Customer.fromJson(json['user'] as Map<String, dynamic>),
      pharmacy: json['pharmacy'] != null
          ? Pharmacy.fromJson(json['pharmacy'] as Map<String, dynamic>)
          : null,
      drugs: (json['drugs'] as List<dynamic>)
          .map((drug) => Drug.fromJson(drug as Map<String, dynamic>))
          .toList(),
      riderId: json['riderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stage': stage,
      'location': location,
      'status': status,
      'eta': eta,
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'pharmacy': pharmacy?.toJson(),
      'drugs': drugs.map((drug) => drug.toJson()).toList(),
      'riderId': riderId,
    };
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDelivered => status == 'delivered';

  String get formattedTotal =>
      'UGX ${NumberFormat('#,###').format(totalAmount.toInt())}';
  String get formattedDeliveryFee =>
      'UGX ${NumberFormat('#,###').format(deliveryFee.toInt())}';

  int get itemCount => drugs.length;

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, y').format(createdAt);
    }
  }

  String get formattedDate => DateFormat('MMM d, y • h:mm a').format(createdAt);

  String get shortLocation {
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }
}
