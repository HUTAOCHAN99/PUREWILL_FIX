// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/repository/plan_repository.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/data/services/badge_notification_service.dart';
import 'package:purewill/data/services/badge_service.dart';
import 'package:purewill/ui/habit-tracker/screen/auth_wrapper.dart';
import 'package:purewill/ui/habit-tracker/screen/badge_xp_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';

final badgeNotificationService = BadgeNotificationService();
late BadgeService badgeService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Initialize Badge Notification Service
    await badgeNotificationService.initialize(
      onBadgeNotificationTap: (payload) {
        _handleBadgeNotification(payload);
      },
    );

    // Initialize Notification Service
    final notificationService = LocalNotificationService();
    await notificationService.initialize(
      onNotificationTap: (payload) {
        _handleNotificationPayload(payload);
      },
    );

    // Handle notification pada app startup
    await LocalNotificationService.handleNotificationOnStartup();

    // Initialize Reminder Sync Service
    await _initializeReminderSyncService();

    // Sync premium status
    final planRepo = PlanRepository();
    await planRepo.syncPremiumStatus();

    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
  }
}

void _handleBadgeNotification(String? payload) {
  if (payload == null) return;
  debugPrint('🎯 Handling badge notification payload: $payload');
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
    } catch (e, stackTrace) {
      retryCount++;
      debugPrint('⚠️ ReminderSyncService initialization attempt $retryCount failed: $e');
      if (retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint('❌ ReminderSyncService initialization failed after $maxRetries attempts');
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
        '/badges': (context) => const BadgeXpScreen(),
        '/logout': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Function untuk check badges ketika user login
Future<void> checkUserBadges(String userId) async {
  try {
    debugPrint('🔍 Checking badges for user: $userId');
    await badgeService.checkAllBadges(userId);
  } catch (e) {
    debugPrint('❌ Error checking user badges: $e');
  }
}

// Global function untuk trigger badge check dari mana saja
Future<void> triggerBadgeCheck(String userId) async {
  await badgeService.checkAllBadges(userId);
}

// Provider untuk badge service
final badgeServiceProvider = Provider<BadgeService>((ref) {
  return badgeService;
});