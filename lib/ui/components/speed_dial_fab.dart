// lib/ui/components/speed_dial_fab.dart
import 'package:flutter/material.dart';

class SpeedDialFab extends StatefulWidget {
  final List<SpeedDialItem> children;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final String? tooltip;

  const SpeedDialFab({
    super.key,
    required this.children,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isOpen) ..._buildSpeedDialItems(),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: widget.backgroundColor ?? const Color(0xFF7C3AED),
            foregroundColor: widget.foregroundColor ?? Colors.white,
            tooltip: widget.tooltip ?? 'Quick Actions',
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
              color: widget.iconColor ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSpeedDialItems() {
    return widget.children.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ScaleTransition(
          scale: _animation,
          child: FloatingActionButton.small(
            heroTag: null, // Important for multiple FABs
            onPressed: () {
              _toggle();
              item.onPressed();
            },
            backgroundColor: item.backgroundColor ?? Colors.white,
            foregroundColor: item.foregroundColor ?? const Color(0xFF7C3AED),
            tooltip: item.tooltip,
            child: Icon(item.icon, size: 20),
          ),
        ),
      );
    }).toList().reversed.toList();
  }
}

class SpeedDialItem {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialItem({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}