import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../models/order.dart';
import '../../../services/api_client.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<Order> _pendingOrders = [];
  List<Order> _acceptedOrders = [];
  List<Order> _deliveredOrders = [];

  bool _isLoadingPending = false;
  bool _isLoadingAccepted = false;
  bool _isLoadingHistory = false;

  String? _error;
  Timer? _refreshTimer;

  OrdersProvider(this._apiClient);

  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get acceptedOrders => _acceptedOrders;
  List<Order> get deliveredOrders => _deliveredOrders;

  bool get isLoadingPending => _isLoadingPending;
  bool get isLoadingAccepted => _isLoadingAccepted;
  bool get isLoadingHistory => _isLoadingHistory;

  String? get error => _error;

  /// Fetch pending orders from the pool
  Future<void> fetchPendingOrders() async {
    _isLoadingPending = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/riders/pending-orders');
      final List<dynamic> ordersJson = response.data as List<dynamic>;
      _pendingOrders = ordersJson
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _error = _apiClient.getErrorMessage(e);
    } finally {
      _isLoadingPending = false;
      notifyListeners();
    }
  }

  /// Fetch orders accepted by this rider
  Future<void> fetchAcceptedOrders() async {
    _isLoadingAccepted = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/riders/accepted-orders');
      final List<dynamic> ordersJson = response.data as List<dynamic>;
      _acceptedOrders = ordersJson
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _error = _apiClient.getErrorMessage(e);
    } finally {
      _isLoadingAccepted = false;
      notifyListeners();
    }
  }

  /// Fetch order history
  Future<void> fetchOrderHistory() async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/riders/order-history');
      final List<dynamic> ordersJson = response.data as List<dynamic>;
      _deliveredOrders = ordersJson
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _error = _apiClient.getErrorMessage(e);
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Accept an order
  Future<Order> acceptOrder(String orderId) async {
    try {
      final response =
          await _apiClient.dio.post('/riders/orders/$orderId/accept');
      final acceptedOrder =
          Order.fromJson(response.data as Map<String, dynamic>);

      // Remove from pending list
      _pendingOrders.removeWhere((order) => order.id == orderId);

      // Add to accepted list
      _acceptedOrders.add(acceptedOrder);

      notifyListeners();
      return acceptedOrder;
    } on DioException catch (e) {
      // If order already accepted by another rider
      if (e.response?.statusCode == 400) {
        // Remove from pending list
        _pendingOrders.removeWhere((order) => order.id == orderId);
        notifyListeners();

        final message = e.response?.data['message'] as String? ??
            'This order is no longer available';
        throw message;
      }
      throw _apiClient.getErrorMessage(e);
    }
  }

  /// Mark an order as delivered
  Future<void> markAsDelivered(String orderId) async {
    try {
      final response =
          await _apiClient.dio.patch('/riders/orders/$orderId/deliver');
      final deliveredOrder =
          Order.fromJson(response.data as Map<String, dynamic>);

      // Remove from accepted list
      _acceptedOrders.removeWhere((order) => order.id == orderId);

      // Add to delivered list
      _deliveredOrders.insert(0, deliveredOrder);

      notifyListeners();
    } on DioException catch (e) {
      throw _apiClient.getErrorMessage(e);
    }
  }

  /// Start auto-refresh for pending orders
  void startAutoRefresh() {
    stopAutoRefresh(); // Stop any existing timer
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (timer) => fetchPendingOrders(),
    );
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final totalEarnings = _deliveredOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );

    final today = DateTime.now();
    final completedToday = _deliveredOrders.where((order) {
      return order.updatedAt.year == today.year &&
          order.updatedAt.month == today.month &&
          order.updatedAt.day == today.day;
    }).length;

    return {
      'pendingCount': _pendingOrders.length,
      'activeCount': _acceptedOrders.length,
      'completedToday': completedToday,
      'totalDeliveries': _deliveredOrders.length,
      'totalEarnings': totalEarnings,
      'averageEarnings': _deliveredOrders.isEmpty
          ? 0.0
          : totalEarnings / _deliveredOrders.length,
    };
  }

  /// Get recent deliveries (last 3)
  List<Order> getRecentDeliveries() {
    return _deliveredOrders.take(3).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
