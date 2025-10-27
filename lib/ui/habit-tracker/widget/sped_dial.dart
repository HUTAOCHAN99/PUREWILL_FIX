import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';

class SpeedDialButton extends StatelessWidget {
  const SpeedDialButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: const Color(0xFF7C3AED),
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Add New Habit',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Edit Habits',
          onTap: () {},
        ),
        SpeedDialChild(
          child: const Icon(Icons.notifications, color: Colors.white),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Reminder Settings',
          onTap: () {},
        ),
      ],
    );
  }
}
