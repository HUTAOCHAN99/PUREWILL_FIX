import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/data/services/badge_notification_service.dart';
import 'package:purewill/data/services/badge_service.dart';
import 'package:purewill/ui/habit-tracker/screen/auth_wrapper.dart';
import 'package:purewill/ui/habit-tracker/screen/badge_xp_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';
import 'package:purewill/ui/auth/screen/resetpassword_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global instances
final badgeNotificationService = BadgeNotificationService();
late BadgeService badgeService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  debugPrint('✅ Supabase initialized');

  // Initialize Badge Notification Service dengan approach yang lebih baik
  await _initializeBadgeNotificationService();

  // Initialize Badge Service
  badgeService = BadgeService(
    Supabase.instance.client,
    badgeNotificationService,
  );

  debugPrint('✅ Badge Service initialized');

  // Initialize existing Notification Service
  final notificationService = LocalNotificationService();
  await notificationService.initialize(
    onNotificationTap: (payload) {
      debugPrint('🔔 General notification tapped with payload: $payload');
      _handleNotificationPayload(payload);
    },
  );

  debugPrint('✅ Local Notification Service initialized');

  // Handle notification pada app startup
  await LocalNotificationService.handleNotificationOnStartup();

  // Initialize Reminder Sync Service dengan retry logic
  await _initializeReminderSyncService();

  debugPrint('🚀 All services initialized successfully');

  // TEST: Force test notifications immediately
  await _testNotificationsImmediately();

  runApp(const ProviderScope(child: MyApp()));
}

// Improved initialization untuk badge notification service
Future<void> _initializeBadgeNotificationService() async {
  try {
    debugPrint('🔄 Initializing Badge Notification Service...');
    
    await badgeNotificationService.initialize(
      onBadgeNotificationTap: (payload) {
        debugPrint('🎯 Badge notification tapped with payload: $payload');
        _handleBadgeNotification(payload);
      },
    );

    // Verify initialization
    if (badgeNotificationService.isInitialized) {
      debugPrint('✅ Badge Notification Service initialized successfully');
      
      // Test immediately setelah initialize
      await _testBadgeNotificationImmediately();
    } else {
      debugPrint('❌ Badge Notification Service failed to initialize');
    }
  } catch (e, stack) {
    debugPrint('❌ Error initializing Badge Notification Service: $e');
    debugPrint('Stack trace: $stack');
  }
}

// Test notifications immediately setelah initialize
Future<void> _testBadgeNotificationImmediately() async {
  try {
    debugPrint('🎯 TESTING NOTIFICATIONS IMMEDIATELY AFTER INIT...');
    
    // Test 1: Basic notification
    await badgeNotificationService.showFloatingBadge(
      badgeName: 'SYSTEM TEST',
      badgeDescription: 'Notification service is working! 🎉',
      badgeId: 9999,
    );

    await Future.delayed(Duration(seconds: 2));

    // Test 2: Progress notification
    await badgeNotificationService.showProgressNotification(
      badgeName: 'Test Achievement',
      currentProgress: 5,
      targetProgress: 10,
      progressType: 'test',
    );

    debugPrint('✅ Immediate notification test completed');
  } catch (e, stack) {
    debugPrint('❌ Immediate notification test failed: $e');
    debugPrint('Stack trace: $stack');
  }
}

// Test semua notifications
Future<void> _testNotificationsImmediately() async {
  try {
    debugPrint('🧪 RUNNING COMPREHENSIVE NOTIFICATION TESTS...');
    
    // Test 1: Badge Notification Service
    debugPrint('📱 Test 1: Badge Notification Service...');
    await badgeNotificationService.showTestBadge();
    
    await Future.delayed(Duration(seconds: 3));
    
    // Test 2: Badge Service dengan force notification
    debugPrint('🏆 Test 2: Badge Service Force Notification...');
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await badgeService.testNotificationsOnly();
    } else {
      debugPrint('ℹ️ No user logged in, skipping badge service test');
    }
    
    debugPrint('✅ All notification tests completed');
  } catch (e, stack) {
    debugPrint('❌ Comprehensive notification test failed: $e');
    debugPrint('Stack trace: $stack');
  }
}

// Handle badge notification payload
void _handleBadgeNotification(String? payload) {
  if (payload == null) return;
  
  debugPrint('🎯 Handling badge notification payload: $payload');
  
  if (payload.startsWith('badge_')) {
    final badgeId = payload.replaceFirst('badge_', '');
    debugPrint('   - Badge ID from notification: $badgeId');
  } else if (payload.startsWith('progress_')) {
    final badgeName = payload.replaceFirst('progress_', '');
    debugPrint('   - Progress notification for: $badgeName');
  }
}

// Handle general notification payload
void _handleNotificationPayload(String? payload) {
  if (payload == null) return;
  
  debugPrint('🎯 Handling general notification payload: $payload');
  
  if (payload.startsWith('habit_')) {
    final habitId = payload.replaceFirst('habit_', '');
    debugPrint('   - Habit ID from notification: $habitId');
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
        '/signup-password': (context) => const ResetPasswordScreen(),
        '/badges': (context) => const BadgeXpScreen(), 
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

// Test function untuk development - DIPERBAIKI
Future<void> testBadgeSystem(String userId) async {
  try {
    debugPrint('🧪 ===== COMPREHENSIVE BADGE SYSTEM TEST =====');
    
    // Test 1: Notifications dulu
    debugPrint('📱 Step 1: Testing notifications...');
    await badgeService.testNotificationsOnly();
    
    await Future.delayed(Duration(seconds: 3));
    
    // Test 2: Badge system
    debugPrint('🏆 Step 2: Testing badge system...');
    await badgeService.testBadgeSystem(userId);
    
    debugPrint('✅ ===== COMPREHENSIVE TEST COMPLETED =====');
  } catch (e, stack) {
    debugPrint('❌ Comprehensive test failed: $e');
    debugPrint('Stack trace: $stack');
  }
}

// Global function untuk trigger badge check dari mana saja
Future<void> triggerBadgeCheck(String userId) async {
  await badgeService.checkAllBadges(userId);
}

// Simple test function untuk notifications saja
Future<void> testSimpleNotification() async {
  try {
    debugPrint('🎯 SIMPLE NOTIFICATION TEST...');
    
    // Paling basic test
    await badgeNotificationService.showFloatingBadge(
      badgeName: 'Simple Test',
      badgeDescription: 'This should appear immediately!',
      badgeId: 12345,
    );
    
    debugPrint('✅ Simple notification test completed');
  } catch (e, stack) {
    debugPrint('❌ Simple notification test failed: $e');
    debugPrint('Stack trace: $stack');
  }
}

// Provider untuk badge service
final badgeServiceProvider = Provider<BadgeService>((ref) {
  return badgeService;
});