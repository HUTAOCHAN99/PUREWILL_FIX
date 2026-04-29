import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/domain/model/target_unit_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/widget/category_dropdown.dart';
import 'package:purewill/ui/habit-tracker/widget/save_button.dart';
import 'package:purewill/ui/auth/auth_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key, this.defaultHabit});
  final HabitModel? defaultHabit;
  factory AddHabitScreen.withDefault(HabitModel defaultHabit) {
    return AddHabitScreen(defaultHabit: defaultHabit);
  }

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetValueController = TextEditingController(text: '30');
  final _customUnitController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationNameController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedFrequency = 'daily';
  int _targetValue = 30;
  String _selectedUnit = 'glasses';
  bool _showCustomUnit = false;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _endDateEnabled = false;
  // Location
  bool _isLocationLocked = false;
  double? _targetLat;
  double? _targetLong;
  int _radius = 50;

  Future<void> onRefresh(WidgetRef ref) async {
    try {
      await ref.read(addHabitNotifierProvider.notifier).loadCategories();
      await ref.read(addHabitNotifierProvider.notifier).loadUnits();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.defaultHabit != null) {
      _isLocationLocked = widget.defaultHabit!.isLocationLocked;
      _locationNameController.text = widget.defaultHabit!.locationName ?? '';
      _targetLat = widget.defaultHabit!.targetLat;
      _targetLong = widget.defaultHabit!.targetLong;
      _radius = widget.defaultHabit!.radius ?? 50;
      _nameController.text = widget.defaultHabit!.name;
      _targetValue = widget.defaultHabit!.targetValue ?? 30;
      _targetValueController.text = _targetValue.toString();
      _selectedFrequency = widget.defaultHabit!.frequency;

      if (widget.defaultHabit!.unit != null) {
        _selectedUnit = widget.defaultHabit!.unit!;
      }
    } else {
      _targetValueController.text = _targetValue.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRefresh(ref);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetValueController.dispose();
    _customUnitController.dispose();
    _noteController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _handleLocationToggle(bool value) async {
    if (value) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Location permission'),
              content: const Text(
                'Location permission is required to lock habit location. Please grant permission in app settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      setState(() {
        _isLocationLocked = true;
      });

      await _showLocationPicker();
    } else {
      setState(() {
        _isLocationLocked = false;
        _targetLat = null;
        _targetLong = null;
      });
    }
  }

  Future<void> _showLocationPicker() async {
    double? tempLat = _targetLat;
    double? tempLong = _targetLong;
    int tempRadius = _radius;

    ll.LatLng center = ll.LatLng(-6.200000, 106.816666);
    try {
      final pos = await Geolocator.getCurrentPosition();
      center = ll.LatLng(pos.latitude, pos.longitude);
      tempLat ??= center.latitude;
      tempLong ??= center.longitude;
    } catch (_) {
      // ignore - use default
      tempLat ??= center.latitude;
      tempLong ??= center.longitude;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: ll.LatLng(tempLat!, tempLong!),
                        initialZoom: 15.0,
                        onTap: (tapPos, point) {
                          setModalState(() {
                            tempLat = point.latitude;
                            tempLong = point.longitude;
                          });
                        },
                      ),
                      // nonRotatedChildren: [],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: ll.LatLng(tempLat!, tempLong!),
                              color: Colors.blue.withOpacity(0.2),
                              borderStrokeWidth: 2,
                              radius: tempRadius.toDouble(),
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: ll.LatLng(tempLat!, tempLong!),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final p =
                                      await Geolocator.getCurrentPosition();
                                  setModalState(() {
                                    tempLat = p.latitude;
                                    tempLong = p.longitude;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to get current location',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Use current location'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tempLat != null && tempLong != null
                                    ? 'Lat: ${tempLat!.toStringAsFixed(6)}, Lng: ${tempLong!.toStringAsFixed(6)}'
                                    : 'Tap map to choose location',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Radius (m):'),
                            Expanded(
                              child: Slider(
                                value: tempRadius.toDouble(),
                                min: 10,
                                max: 1000,
                                divisions: 99,
                                label: '\$tempRadius m',
                                onChanged: (v) =>
                                    setModalState(() => tempRadius = v.toInt()),
                              ),
                            ),
                            Text('$tempRadius'),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _targetLat = tempLat;
                                    _targetLong = tempLong;
                                    _radius = tempRadius;
                                  });
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('Save Location'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final addHabitViewModel = ref.read(addHabitNotifierProvider.notifier);
      final addHabitState = ref.read(addHabitNotifierProvider);

      final authState = ref.read(authNotifierProvider);
      final currentUser = authState.user;

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in')),
          );
        }
        return;
      }

      try {
        final matchedUnit = addHabitState.units
            .where((unit) => unit.name == _selectedUnit)
            .cast<TargetUnitModel?>()
            .firstWhere((unit) => unit != null, orElse: () => null);

        await addHabitViewModel.addHabit(
          name: _nameController.text,
          frequency: _selectedFrequency,
          categoryId: _selectedCategoryId,
          unitId: matchedUnit?.id,
          startDate: _startDate ?? DateTime.now(),
          endDate: _endDateEnabled ? _endDate : null,
          notes: _noteController.text,
          targetValue: _targetValue,
          reminderEnabled: _reminderEnabled,
          reminderTime: _reminderTime,
          isLocationLocked: _isLocationLocked,
          locationName: _locationNameController.text.isNotEmpty
              ? _locationNameController.text
              : null,
          targetLat: _targetLat,
          targetLong: _targetLong,
          radius: _radius,
        );

        await ref.read(habitNotifierProvider.notifier).loadUserHabits();
        await ref.read(homeNotifierProvider.notifier).initializeHome();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit berhasil ditambahkan!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add habit: $e'),
              backgroundColor: Colors.red,
            ),
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
    final addHabitState = ref.watch(addHabitNotifierProvider);
    final List<CategoryModel> userCategories = addHabitState.categories;
    final List<String> loadedUnitOptions = addHabitState.units
        .map((unit) => unit.name)
        .toList();
    final List<String> unitOptions = loadedUnitOptions;
    final List<String> unitOptionsSafe = unitOptions.isNotEmpty
        ? unitOptions
        : ['other'];
    final String selectedUnitValue = unitOptionsSafe.contains(_selectedUnit)
        ? _selectedUnit
        : unitOptionsSafe.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
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
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
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
                            color: Colors.black.withValues(alpha: 0.1),
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
                          fillColor: Colors.white.withValues(alpha: 0.95),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
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
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
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
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedUnitValue,
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
                                items: unitOptionsSafe
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
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
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

                    // Start Date Field
                    const Text(
                      'Start Date',
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _startDate != null
                                    ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
                                    : 'Select start date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _startDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // End Date Field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Switch(
                                  value: _endDateEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _endDateEnabled = value;
                                      if (!value) {
                                        _endDate = null;
                                      }
                                    });
                                  },
                                  activeColor: Colors.purple,
                                ),
                              ],
                            ),
                            if (_endDateEnabled) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Select End Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _endDate ??
                                        DateTime.now().add(
                                          const Duration(days: 30),
                                        ),
                                    firstDate: _startDate ?? DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null && mounted) {
                                    setState(() {
                                      _endDate = picked;
                                    });
                                  }
                                },
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
                                        _endDate != null
                                            ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
                                            : 'Select end date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _endDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
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

                    // Location Lock
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Lock Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Switch(
                                  value: _isLocationLocked,
                                  onChanged: (v) => _handleLocationToggle(v),
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                            if (_isLocationLocked) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Location Name',
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
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _locationNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    hintText: 'e.g. Office, Home, Gym',
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.95,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _showLocationPicker,
                                child: Text(
                                  _targetLat != null && _targetLong != null
                                      ? 'Change Location'
                                      : 'Pick Location on Map',
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_targetLat != null &&
                                  _targetLong != null) ...[
                                Text('Lat: ${_targetLat!.toStringAsFixed(6)}'),
                                Text('Lng: ${_targetLong!.toStringAsFixed(6)}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Radius (m):'),
                                    const SizedBox(width: 8),
                                    Text('$_radius'),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Note Field
                    const Text(
                      'Note',
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add your notes here...',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.95),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SaveButton(onPressed: _saveHabit),
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
