import 'package:flutter/material.dart';

class CleanBottomNavigationBar extends StatelessWidget{
  final int currentIndex;
  final Function onTap;
  const CleanBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
   return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1.0)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        elevation: 0,
        // onTap: (index) {
        //   setState(() {
        //     _currentIndex = index;
        //   });
        //   if (index == 2) {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(builder: (context) => const AddHabitScreen()),
        //     );
        //     Future.delayed(const Duration(milliseconds: 300), () {
        //       if (mounted) {
        //         setState(() {
        //           _currentIndex = 0;
        //         });
        //       }
        //     });
        //   }
        // },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            activeIcon: Icon(Icons.chat_bubble, size: 24),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 24),
            activeIcon: Icon(Icons.add_circle, size: 24),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined, size: 24),
            activeIcon: Icon(Icons.chat, size: 24),
            label: 'Forum',
          ),
        ],
      ),
    );
  }

}