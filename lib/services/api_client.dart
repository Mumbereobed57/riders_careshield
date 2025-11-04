import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    // Allow overriding base URL via --dart-define=API_BASE_URL=http://host:3000/api
    const envBase = String.fromEnvironment('API_BASE_URL');

    // Use production API for Android by default, local for iOS/desktop during development
    final defaultBase = Platform.isAndroid
        ? AppConstants.productionApiUrl
        : AppConstants.localApiUrl;

    dio.options.baseUrl = envBase.isNotEmpty ? envBase : defaultBase;

    // Add timeout configurations
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ignore: avoid_print
          print('[API Request] ${options.method} ${options.uri}');
          if (options.data != null) {
            // ignore: avoid_print
            print('[API Request Body] ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('[API Response] ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // ignore: avoid_print
          print('[API Error] ${error.response?.statusCode} ${error.requestOptions.uri}');
          // ignore: avoid_print
          print('[API Error Message] ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );

    // Add auth token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // ignore: avoid_print
            print('[API Auth] Token attached to request');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle token expiration (401 Unauthorized)
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - clear it
            await secureStorage.delete(key: AppConstants.tokenKey);
            // ignore: avoid_print
            print('[API Auth] Token cleared due to 401 response');
          }
          return handler.next(error);
        },
      ),
    );

    // Debug which base URL is in use
    // ignore: avoid_print
    print('[ApiClient] Initialized with Base URL: ${dio.options.baseUrl}');
  }

  // Helper method to handle API errors
  String getErrorMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data['message'];

      if (statusCode == 400 && message != null) {
        return message;
      } else if (statusCode == 401) {
        return 'Session expired. Please login again.';
      } else if (statusCode == 403) {
        return 'You do not have permission to perform this action.';
      } else if (statusCode == 404) {
        return 'Resource not found.';
      } else if (statusCode! >= 500) {
        return 'Server error. Please try again later.';
      }
    }

    if (error.type == DioExceptionType.unknown) {
      return 'Network error. Please check your internet connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
