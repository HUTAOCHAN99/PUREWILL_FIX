import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/ui/habit-tracker/screen/auth_wrapper.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';
import 'package:purewill/ui/auth/screen/resetpassword_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // **FIX: Remove options parameter yang tidak ada**
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  debugPrint('✅ Supabase initialized');

  // Initialize Notification Service dengan background support
  final notificationService = LocalNotificationService();
  await notificationService.initialize(
    onNotificationTap: (payload) {
      debugPrint('🔔 Notification tapped with payload: $payload');
      // Handle notification tap - bisa digunakan untuk deep linking
      _handleNotificationPayload(payload);
    },
  );

  debugPrint('✅ Local Notification Service initialized');

  // Handle notification pada app startup
  await LocalNotificationService.handleNotificationOnStartup();

  // Initialize Reminder Sync Service dengan retry logic
  await _initializeReminderSyncService();

  debugPrint('🚀 All services initialized successfully');

  runApp(const ProviderScope(child: MyApp()));
}

// Handle notification payload untuk deep linking
void _handleNotificationPayload(String? payload) {
  if (payload == null) return;
  
  debugPrint('🎯 Handling notification payload: $payload');
  
  if (payload.startsWith('habit_')) {
    final habitId = payload.replaceFirst('habit_', '');
    debugPrint('   - Habit ID from notification: $habitId');
    
  } else if (payload.startsWith('test_')) {
    debugPrint('   - Test notification tapped');
  }
}

// Initialize Reminder Sync Service dengan retry mechanism
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
      debugPrint('❌ Retry $retryCount/$maxRetries: Error initializing ReminderSyncService: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (retryCount < maxRetries) {
        debugPrint('🔄 Retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint('⚠️ ReminderSyncService initialization failed after $maxRetries attempts');
        debugPrint('💡 Notifications might not work properly in background');
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
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signup-password': (context) => const ResetPasswordScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}