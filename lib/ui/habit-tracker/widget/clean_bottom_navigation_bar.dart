import 'package:flutter/material.dart';
import 'package:purewill/ui/habit-tracker/screen/community_selection_screen.dart';

class CleanBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
// <<<<<<< HEAD

// =======
  
// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
  const CleanBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        elevation: 0,
// <<<<<<< HEAD
// =======
        // onTap: (index) {
        //   // Handle navigation untuk komunitas (index 3)
        //   if (index == 3) {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => const CommunitySelectionScreen(),
        //       ),
        //     );
        //   } else {
        //     onTap(index);
        //   }
        // },
// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
// <<<<<<< HEAD
//             icon: Icon(Icons.settings_outlined),
//             activeIcon: Icon(Icons.settings),
//             label: 'Settings',
// =======
            icon: Icon(Icons.add_circle_outline, size: 24),
            activeIcon: Icon(Icons.add_circle, size: 24),
            label: 'Add Habit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 24), // Ubah icon
            activeIcon: Icon(Icons.people, size: 24), // Ubah icon aktif
            label: 'Komunitas',
// >>>>>>> f2d2932ae1d617906d117abaeeb90fd7045aea0c
          ),
        ],
      ),
    );
  }
}
