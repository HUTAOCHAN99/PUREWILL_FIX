import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/ui/habit-tracker/screen/auth_wrapper.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';
import 'package:purewill/utils/indonesia_timezone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeIndonesiaTimezone();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Tampilkan konfigurasi API
  _printApiConfig();

  // Initialize services
  await _initializeServices();

  runApp(const ProviderScope(child: MyApp()));
}

void _printApiConfig() {
  final host = dotenv.env['API_HOST'] ?? 'localhost';
  final port = dotenv.env['API_PORT'] ?? '4000';
  final baseUrl = 'http://$host:$port/api';

  debugPrint('═══════════════════════════════════════════');
  debugPrint('🌐 API Configuration:');
  debugPrint('   Host: $host');
  debugPrint('   Port: $port');
  debugPrint('   Base URL: $baseUrl');
  debugPrint('═══════════════════════════════════════════');
}

Future<void> _initializeServices() async {
  try {
    // Initialize Notification Service
    final notificationService = LocalNotificationService();
    await notificationService.initialize(
      onNotificationTap: (payload) {
        _handleNotificationPayload(payload);
      },
    );

    // Handle notification pada app startup
    await LocalNotificationService.handleNotificationOnStartup();
    await _initializeReminderSyncService();

    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
  }
}

void _handleNotificationPayload(String? payload) {
  if (payload == null) return;
  debugPrint('🎯 Handling general notification payload: $payload');
}

Future<void> _initializeReminderSyncService() async {
  bool syncInitialized = false;
  int retryCount = 0;
  const maxRetries = 3;

  while (!syncInitialized && retryCount < maxRetries) {
    try {
      await ReminderSyncService().initialize();
      syncInitialized = true;
      debugPrint('✅ ReminderSyncService initialized successfully');
    } catch (e) {
      retryCount++;
      debugPrint(
        '⚠️ ReminderSyncService initialization attempt $retryCount failed: $e',
      );
      if (retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint(
          '❌ ReminderSyncService initialization failed after $maxRetries attempts',
        );
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureWill',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/logout': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
