import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/auth/biometric_service.dart';
import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/ui/auth/auth_provider.dart';

class FingerprintLockPage extends ConsumerStatefulWidget {
  const FingerprintLockPage({super.key});

  @override
  ConsumerState<FingerprintLockPage> createState() =>
      _FingerprintLockPageState();
}

class _FingerprintLockPageState extends ConsumerState<FingerprintLockPage> {
  final BiometricService _biometricService = BiometricService();
  int _attempts = 0;
  bool _authInProgress = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAuth());
  }

  Future<void> _startAuth() async {
    if (_authInProgress) return;
    setState(() {
      _authInProgress = true;
      _message = null;
    });

    final storage = SecureStorageRepository();
    final enabled = await storage.isBiometricEnabled();
    if (!enabled) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      final result = await _biometricService.authenticate(
        reason: 'Unlock PureWill',
        title: 'Fingerprint required',
        subtitle: 'Use your fingerprint to continue',
        cancelButtonText: 'Use Password',
      );

      if (!result.success) {
        _attempts += 1;
        if (_attempts >= 3) {
          // Clear biometric session and require password login
          await ref.read(authNotifierProvider.notifier).clearSavedCredentials();
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }

        setState(() {
          _message = result.errorMessage ?? 'Authentication failed';
          _authInProgress = false;
        });
        return;
      }

      // Success: restore session using refresh token and proceed
      setState(() {
        _message = 'Authenticated, restoring session...';
      });
      await ref.read(authNotifierProvider.notifier).restoreSession();

      final authState = ref.read(authNotifierProvider);
      if (authState.user != null) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
        return;
      }

      // If restore failed, go to login
      await ref.read(authNotifierProvider.notifier).clearSavedCredentials();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      setState(() {
        _message = 'Authentication error: $e';
        _authInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 72, color: Colors.black87),
              const SizedBox(height: 16),
              Text(
                _authInProgress
                    ? 'Waiting for fingerprint...'
                    : (_message ?? 'Place your finger on the sensor'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (!_authInProgress)
                ElevatedButton(
                  onPressed: _startAuth,
                  child: const Text('Try again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
