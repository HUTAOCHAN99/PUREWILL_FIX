import 'package:flutter/material.dart' hide Badge; // Hide Flutter's Badge
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/badge_model.dart' as models; // Use alias
import 'package:purewill/ui/badge/providers/badge_provider.dart';
import 'package:purewill/ui/badge/ui/components/badge_card.dart';
import 'package:purewill/ui/badge/ui/components/level_progress.dart';
import 'package:purewill/ui/badge/ui/components/streak_alert.dart';
import 'package:purewill/ui/badge/ui/components/xp_progress.dart';

class BadgeXpScreen extends ConsumerWidget {
  const BadgeXpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: badgesAsync.when(
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(error: error, ref: ref),
        data: (badges) => _ContentState(badges: badges),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Badge & XP',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final WidgetRef ref;

  const _ErrorState({required this.error, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(badgesProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentState extends StatelessWidget {
  final List<models.Badge> badges;

  const _ContentState({required this.badges});

  @override
  Widget build(BuildContext context) {
    final unlockedBadges = badges.where((b) => b.isUnlocked).toList();
    final lockedBadges = badges.where((b) => !b.isUnlocked).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StreakAlert(),
          const SizedBox(height: 24),
          const LevelProgress(),
          const SizedBox(height: 24),
          const XpProgress(),
          const SizedBox(height: 24),
          if (unlockedBadges.isNotEmpty) ...[
            _BadgeSection(
              title: 'Earned Badges',
              subtitle: '${unlockedBadges.length} Badges Earned',
              badges: unlockedBadges,
              isUnlocked: true,
            ),
            const SizedBox(height: 24),
          ],
          if (lockedBadges.isNotEmpty) ...[
            _BadgeSection(
              title: 'Locked Badges',
              subtitle: '${lockedBadges.length} Badges to Earn',
              badges: lockedBadges,
              isUnlocked: false,
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _BadgeSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<models.Badge> badges;
  final bool isUnlocked;

  const _BadgeSection({
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) => BadgeCard(
            badge: badges[index],
            isUnlocked: isUnlocked,
          ),
        ),
      ],
    );
  }
}