import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final supabaseClient = ref.read(supabaseClientProvider);
    supabaseClient.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      // print('Auth state changed: $event');
      // print('Session: ${session != null ? "Active" : "None"}');
      
      if (event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabaseClient = ref.read(supabaseClientProvider);
    final currentUser = supabaseClient.auth.currentUser;

    // print('AuthWrapper - Current User: ${currentUser?.email}');

    if (currentUser != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}