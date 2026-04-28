import 'package:flutter/material.dart';
import 'package:purewill/ui/habit-tracker/screen/category_list_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/unit_list_screen.dart';

class CategoryUnitManagementScreen extends StatelessWidget {
  const CategoryUnitManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Category & Unit Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Category'),
              Tab(text: 'Unit'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CategoryListScreen(), UnitListScreen()],
        ),
      ),
    );
  }
}
