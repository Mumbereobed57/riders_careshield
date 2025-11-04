import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/dashboard/screens/home_screen.dart';
import 'core/widgets/loading_indicator.dart';

class RidersApp extends StatelessWidget {
  const RidersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareShield Riders',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState to avoid calling during build
    _authCheckFuture = _checkAuthStatus();
  }

  Future<bool> _checkAuthStatus() async {
    // Use context.read() which is safe in async methods
    final authProvider = context.read<AuthProvider>();
    return await authProvider.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheckFuture,
      builder: (context, snapshot) {
        // Show loading while checking auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Loading...'),
          );
        }

        // Check if authenticated
        final isAuthenticated = snapshot.data ?? false;

        // Navigate to appropriate screen
        return isAuthenticated ? const HomeScreen() : const WelcomeScreen();
      },
    );
  }
}
