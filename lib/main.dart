import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/ui/habit-tracker/screen/auth_wrapper.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/auth/screen/signup_screen.dart';
import 'package:purewill/ui/auth/screen/resetpassword_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await LocalNotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureWill',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signup-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
