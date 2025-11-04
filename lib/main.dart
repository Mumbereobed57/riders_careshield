import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'services/api_client.dart';
import 'services/local_storage_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/orders/providers/orders_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default system UI overlay style for the entire app
  SystemChrome.setSystemUIOverlayStyle(
    getSystemUiOverlayStyle(statusBarColor: AppColors.surface),
  );

  // Suppress known Flutter framework assertion errors in debug mode
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Filter out the pointer tracking assertion error
      if (details.exception.toString().contains('PointerAddedEvent') ||
          details.exception.toString().contains('PointerRemovedEvent')) {
        // Suppress this known Flutter framework issue
        return;
      }
      // Report all other errors normally
      FlutterError.presentError(details);
    };
  }

  // Initialize local storage
  await LocalStorageService.init();

  // Initialize dependencies
  final dio = Dio();
  const secureStorage = FlutterSecureStorage();
  final apiClient = ApiClient(dio: dio, secureStorage: secureStorage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient, secureStorage),
        ),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
      ],
      child: const RidersApp(),
    ),
  );
}
