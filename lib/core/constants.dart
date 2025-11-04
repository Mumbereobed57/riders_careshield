import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF2563EB); // #2563EB
  static const secondaryGreen = Color(0xFF10B981); // #10B981
  static const background = Color(0xFFF8FAFC); // #F8FAFC
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1E293B); // #1E293B
  static const accent = Color(0xFFF59E0B); // #F59E0B
  static const error = Color(0xFFEF4444); // #EF4444
}

class AppConstants {
  // API Base URLs
  static const String productionApiUrl = 'https://care-shield.onrender.com/api';
  static const String localApiUrl = 'http://192.168.70.23:3000/api';

  // Storage Keys
  static const String tokenKey = 'rider_token';
  static const String userDataKey = 'rider_user_data';

  // Auto-refresh intervals (in seconds)
  static const int pendingOrdersRefreshInterval = 15;
  static const int statsRefreshInterval = 30;

  // App Info
  static const String appName = 'CareShield Riders';
  static const String appTagline = 'Deliver health, earn with purpose';
}
