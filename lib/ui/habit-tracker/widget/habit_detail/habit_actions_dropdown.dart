// lib\ui\habit-tracker\widget\habit_actions_dropdown.dart
import 'package:flutter/material.dart';

class HabitActionsDropdown extends StatelessWidget {
  final Function(String) onActionSelected;
  final String habitName;

  const HabitActionsDropdown({
    super.key,
    required this.onActionSelected,
    required this.habitName,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: onActionSelected,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Edit Habit'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'reminder',
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Reminder Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete Habit'),
            ],
          ),
        ),
      ],
    );
  }

  // Static method untuk show delete confirmation dialog
  static void showDeleteConfirmationDialog({
    required BuildContext context,
    required String habitName,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "$habitName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Static method untuk handle menu actions dengan default behavior
  static void handleMenuAction({
    required String value,
    required BuildContext context,
    required String habitName,
    VoidCallback? onEdit,
    VoidCallback? onReminder,
    VoidCallback? onDelete,
  }) {
    switch (value) {
      case 'edit':
        if (onEdit != null) {
          onEdit();
        } else {
          _showComingSoonSnackBar(context, 'Edit Habit');
        }
        break;
      case 'reminder':
        if (onReminder != null) {
          onReminder();
        } else {
          _showComingSoonSnackBar(context, 'Reminder Settings');
        }
        break;
      case 'delete':
        if (onDelete != null) {
          onDelete();
        } else {
          showDeleteConfirmationDialog(
            context: context,
            habitName: habitName,
            onConfirm: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$habitName" deleted')),
              );
              Navigator.pop(context); // Kembali ke home setelah delete
            },
          );
        }
        break;
    }
  }

  static void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Coming Soon')),
    );
  }
}