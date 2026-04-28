import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/widget/category_dropdown.dart';
import 'package:purewill/ui/habit-tracker/widget/save_button.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _customUnitController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedFrequency = 'daily';
  int _targetValue = 30;
  String _selectedUnit = 'glasses';
  bool _showCustomUnit = false;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  final List<String> _unitOptions = [
    'glasses',
    'pages',
    'minutes',
    'hours',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormWithHabitData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitNotifierProvider.notifier).loadCategories();
    });
  }

  void _initializeFormWithHabitData() {
    final habit = widget.habit;

    _nameController.text = habit.name;
    _notesController.text = habit.notes ?? '';
    _targetValue = habit.targetValue ?? 30;
    _targetValueController.text = _targetValue.toString();
    _selectedFrequency = habit.frequency;
    _selectedCategoryId = habit.category?.id;

    if (habit.unit != null) {
      if (_unitOptions.contains(habit.unit)) {
        _selectedUnit = habit.unit!;
        _showCustomUnit = false;
      } else {
        _selectedUnit = 'other';
        _showCustomUnit = true;
        _customUnitController.text = habit.unit!;
      }
    }

    _reminderEnabled = habit.reminderEnabled;
    _reminderTime = habit.reminderTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _targetValueController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _updateHabit() async {
    if (_formKey.currentState!.validate()) {
      // print("tombol update ditekan");

      try {
        final viewModel = ref.read(habitNotifierProvider.notifier);
        final originalHabit = widget.habit;

        final updateData = <String, dynamic>{};

        final name = _nameController.text.trim();
        if (name != originalHabit.name) {
          updateData['name'] = name;
        }

        final notes = _notesController.text.trim();
        final originalNotes = originalHabit.notes?.trim() ?? '';
        if (notes != originalNotes && notes.isNotEmpty) {
          updateData['notes'] = notes;
        }

        if (_selectedFrequency != originalHabit.frequency) {
          updateData['frequencyType'] = _selectedFrequency.toUpperCase();
        }

        if (_selectedCategoryId != null &&
            _selectedCategoryId != originalHabit.category?.id) {
          updateData['categoryId'] = _selectedCategoryId;
        }

        if (_targetValue != originalHabit.targetValue) {
          updateData['targetValue'] = _targetValue;
        }

        if (_reminderEnabled != originalHabit.reminderEnabled) {
          updateData['reminderEnabled'] = _reminderEnabled;
        }

        await viewModel.updateHabitFields(
          habitId: widget.habit.id,
          updates: updateData,
        );

        // print('=== HABIT UPDATED SUCCESS ===');

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit berhasil diperbarui!')),
          );
        }
      } catch (error) {
        // print('=== HABIT UPDATE ERROR: $error ===');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui habit: $error')),
          );
        }
      }
    }
  }

  void _handleCategoryChange(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitNotifierProvider);
    final List<CategoryModel> userCategories = habitState.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        backgroundColor: const Color.fromRGBO(176, 230, 216, 1),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/home/bg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habit Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Morning Meditation',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.95),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter habit name';
                          }
                          if (value.length < 2) {
                            return 'Habit name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Add notes for this habit',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.95),
                          counterStyle: TextStyle(color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          final notes = value?.trim() ?? '';
                          if (notes.isNotEmpty && notes.length < 5) {
                            return 'Notes must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CategoryDropdown(
                          userCategories: userCategories,
                          selectedCategoryId: _selectedCategoryId,
                          onChanged: _handleCategoryChange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Target',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: _targetValueController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Value',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                onChanged: (value) {
                                  final parsedValue = int.tryParse(value) ?? 30;
                                  setState(() {
                                    _targetValue = parsedValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter target value';
                                  }
                                  final parsed = int.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Please enter valid target value';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                items: _unitOptions
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(
                                          unit == 'other' ? 'Other...' : unit,
                                          style: TextStyle(
                                            color: unit == 'other'
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value!;
                                    _showCustomUnit = value == 'other';
                                    if (value != 'other') {
                                      _customUnitController.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_showCustomUnit) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Custom Unit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _customUnitController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: 'e.g. cups, km, sets, etc.',
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: (value) {
                              if (_selectedUnit == 'other' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter custom unit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    Text(
                      'Target: $_targetValue ${_showCustomUnit && _customUnitController.text.isNotEmpty
                          ? _customUnitController.text
                          : _selectedUnit != 'other'
                          ? _selectedUnit
                          : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Switch(
                                  value: _reminderEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _reminderEnabled = value;
                                      if (value && _reminderTime == null) {
                                        _reminderTime = TimeOfDay.now();
                                      }
                                    });
                                  },
                                  activeColor: Colors.purple,
                                ),
                              ],
                            ),
                            if (_reminderEnabled) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Reminder Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _selectReminderTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _reminderTime != null
                                            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Select time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _reminderTime != null
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SaveButton(onPressed: _updateHabit, text: 'Update Habit'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
