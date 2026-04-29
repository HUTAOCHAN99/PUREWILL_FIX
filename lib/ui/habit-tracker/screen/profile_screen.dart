import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/auth/biometric_service.dart';
import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/habit-tracker/provider/profile_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricEnabled = false;

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final vm = ref.read(profileViewModelProvider.notifier);
    final success = await vm.logout();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    final state = ref.read(profileViewModelProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errorMessage ?? 'Logout failed')),
    );
  }

  Future<void> _loadBiometricEnabled() async {
    final storage = SecureStorageRepository();
    final enabled = await storage.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    try {
      await ref.read(profileViewModelProvider.notifier).loadProfile();
      await _loadBiometricEnabled();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadBiometricEnabled(),
    );
  }

  String _initials(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return cleaned.substring(0, 1).toUpperCase();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final user = state.user;
    final currentUser = user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: state.isLoading && user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(
                            0xFF7C3AED,
                          ).withOpacity(0.12),
                          child: Text(
                            _initials(
                              user?.fullName ??
                                  user?.username ??
                                  user?.email ??
                                  'U',
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.fullName?.trim().isNotEmpty == true
                              ? user!.fullName!
                              : (user?.username?.trim().isNotEmpty == true
                                    ? user!.username!
                                    : 'User'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'User Info',
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Full Name',
                          value: user?.fullName?.trim().isNotEmpty == true
                              ? user!.fullName!
                              : '-',
                        ),
                        const Divider(height: 24),
                        _InfoRow(label: 'Email', value: user?.email ?? '-'),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Username',
                          value: user?.username?.trim().isNotEmpty == true
                              ? user!.username!
                              : '-',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Phone Number',
                          value: user?.phoneNumber?.trim().isNotEmpty == true
                              ? user!.phoneNumber!
                              : '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Biometric toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Enable Fingerprint Login',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Use fingerprint to quickly unlock the app',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _biometricEnabled,
                          onChanged: (val) async {
                            if (state.user == null) return;

                            if (val) {
                              // Enable biometric: check device support and enrolled biometrics
                              final available = await _biometricService
                                  .isBiometricAvailable();
                              final types = await _biometricService
                                  .getAvailableBiometrics();
                              if (!available || types.isEmpty) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Biometric not available or not enrolled on this device',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final authResult = await _biometricService
                                  .authenticate(
                                    reason:
                                        'Authenticate to enable fingerprint login',
                                    title: 'Enable Fingerprint',
                                    subtitle:
                                        'Verify your fingerprint to enable',
                                    cancelButtonText: 'Cancel',
                                  );

                              if (!authResult.success) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authResult.errorMessage ??
                                          'Authentication failed',
                                    ),
                                  ),
                                );
                                return;
                              }

                              // Save preference (we do not save password). Tokens are already stored.
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .saveCredentialsForBiometric(
                                    email: state.user!.email,
                                    enableBiometric: true,
                                  );
                              if (!mounted) return;
                              setState(() {
                                _biometricEnabled = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fingerprint login enabled'),
                                ),
                              );
                            } else {
                              // Disable
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .clearSavedCredentials();
                              if (!mounted) return;
                              setState(() {
                                _biometricEnabled = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fingerprint login disabled'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed:
                        state.isLogoutLoading || state.isLoading || user == null
                        ? null
                        : () async {
                            if (currentUser == null) return;
                            final result = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(user: currentUser),
                                  ),
                                );
                            if (result == true) {
                              await _onRefresh(ref);
                            }
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit User'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.isLogoutLoading
                        ? null
                        : () => _showLogoutDialog(context, ref),
                    icon: state.isLogoutLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      state.isLogoutLoading ? 'Logging out...' : 'Logout',
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
