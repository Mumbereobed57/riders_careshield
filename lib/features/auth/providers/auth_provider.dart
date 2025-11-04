import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../models/rider.dart';
import '../../../services/api_client.dart';
import '../../../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  Rider? _currentRider;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiClient, this._secureStorage);

  Rider? get currentRider => _currentRider;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentRider != null;

  /// Check if user is logged in on app startup
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return false;
      }

      // Try to fetch user profile
      final response = await _apiClient.dio.get('/auth/me');
      _currentRider = Rider.fromJson(response.data);
      notifyListeners();
      return true;
    } catch (e) {
      // Token invalid or expired
      await logout();
      return false;
    }
  }

  /// Sign up a new rider
  Future<void> signup({
    required String fullName,
    required String phone,
    required String password,
    required String vehicleType,
    required String licenseNumber,
    String? email,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: {
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'role': 'rider',
          'vehicleType': vehicleType,
          'licenseNumber': licenseNumber,
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Save token
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);

      // Save user data
      _currentRider = Rider.fromJson(userData);
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userData),
      );

      notifyListeners();
    } on DioException catch (e) {
      _error = _apiClient.getErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Login an existing rider
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Verify the user is a rider
      if (userData['role'] != 'rider') {
        throw Exception('Invalid account type. Please use the CareShield customer app.');
      }

      // Save token
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);

      // Save user data
      _currentRider = Rider.fromJson(userData);
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userData),
      );

      notifyListeners();
    } on DioException catch (e) {
      _error = _apiClient.getErrorMessage(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the current rider
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.userDataKey);
    _currentRider = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
