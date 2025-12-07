// lib\ui\habit-tracker\widget\habit_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/plan_model.dart';
import 'package:purewill/ui/habit-tracker/screen/badge_xp_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/membership_screen.dart';
import 'package:purewill/ui/habit-tracker/widget/menu_button.dart';

class HabitHeader extends ConsumerWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final bool isPremiumUser;
  final PlanModel? currentPlan;

  const HabitHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    this.isPremiumUser = false,
    this.currentPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(176, 230, 216, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'PureWill',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          // Avatar dengan badge premium
          _buildUserAvatarWithPremium(context),
        ],
      ),
    );
  }

  Widget _buildUserAvatarWithPremium(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPremiumUser ? Colors.yellow : Colors.grey.shade300,
              width: isPremiumUser ? 2 : 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: isPremiumUser ? Colors.deepPurple[50] : Colors.white,
            child: IconButton(
              icon: Icon(
                Icons.person,
                color: isPremiumUser ? Colors.deepPurple : const Color(0xFF7C3AED),
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showUserProfileMenu(context),
            ),
          ),
        ),
        
        // Badge premium kecil di sudut
        if (isPremiumUser)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.deepPurple,
                  size: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showUserProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Avatar dengan status premium
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isPremiumUser 
                            ? Colors.deepPurple 
                            : const Color(0xFF7C3AED),
                        child: const Icon(
                          Icons.person, 
                          color: Colors.white, 
                          size: 30
                        ),
                      ),
                      if (isPremiumUser)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.deepPurple),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.deepPurple,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  // Tampilkan status membership
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPremiumUser 
                          ? Colors.deepPurple.withOpacity(0.1) 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPremiumUser 
                            ? Colors.deepPurple.withOpacity(0.3)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPremiumUser ? Icons.star : Icons.person_outline,
                          color: isPremiumUser ? Colors.deepPurple : Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPremiumUser 
                              ? (currentPlan?.name ?? 'Premium Member')
                              : 'Free Member',
                          style: TextStyle(
                            color: isPremiumUser ? Colors.deepPurple : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
// <<<<<<< HEAD

// =======
                  
                  // Menu items - VERSI SEDERHANA tanpa subtitle/badgeCount
// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
                  MenuButton(
                    icon: Icons.emoji_events_outlined,
                    title: 'Badge & XP',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToBadgeXpScreen(context);
                    },
                  ),

                  MenuButton(
                    icon: isPremiumUser ? Icons.star : Icons.upgrade,
                    title: isPremiumUser ? 'My Membership' : 'Upgrade to Premium',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToMembershipScreen(context);
                    },
                  ),
                  
                  MenuButton(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => Navigator.pop(context),
                  ),
                  
                  MenuButton(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.pop(context),
                  ),
                  
                  MenuButton(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => Navigator.pop(context),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// <<<<<<< HEAD
// =======
  void _navigateToMembershipScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MembershipScreen(),
      ),
    );
  }

// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
  void _navigateToBadgeXpScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const BadgeXpScreen()));
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogout();
// <<<<<<< HEAD
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 '/logout',
//                 (route) => false,
//               );
// =======
// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
