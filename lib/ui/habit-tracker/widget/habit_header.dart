import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitHeader extends ConsumerWidget {
  final String? userName;
  final String? userEmail;
  final VoidCallback onLogout;

  const HabitHeader({super.key, required this.userName, required this.userEmail, required this.onLogout});


  // void _showUserProfileMenu() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade300,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             const CircleAvatar(
  //               radius: 30,
  //               backgroundColor: Color(0xFF7C3AED),
  //               child: Icon(Icons.person, color: Colors.white, size: 30),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               userName,
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             Text(
  //               userEmail,
  //               style: const TextStyle(color: Colors.grey, fontSize: 14),
  //             ),
  //             const SizedBox(height: 20),
  //             MenuButton(
  //               icon: Icons.settings_outlined,
  //               title: 'Settings',
  //               onTap: () => Navigator.pop(context),
  //             ),
  //             MenuButton(
  //               icon: Icons.help_outline,
  //               title: 'Help & Support',
  //               onTap: () => Navigator.pop(context),
  //             ),
  //             MenuButton(
  //               icon: Icons.info_outline,
  //               title: 'About',
  //               onTap: () => Navigator.pop(context),
  //             ),
  //             const SizedBox(height: 10),
  //             Container(
  //               width: double.infinity,
  //               margin: const EdgeInsets.only(top: 10),
  //               child: OutlinedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   _showLogoutConfirmation(context, ref);
  //                 },
  //                 style: OutlinedButton.styleFrom(
  //                   foregroundColor: Colors.red,
  //                   side: const BorderSide(color: Colors.red),
  //                   padding: const EdgeInsets.symmetric(vertical: 12),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: const Text('Logout'),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF7C3AED),
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => {},
                // onPressed: _showUserProfileMenu,
              ),
            ),
          ),
        ],
      ),
    );

    
  }

  
  // void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Logout'),
  //       content: const Text('Are you sure you want to logout?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             onLogout();
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  
}
