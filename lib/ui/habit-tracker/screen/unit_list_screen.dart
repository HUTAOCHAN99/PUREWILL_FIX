import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/provider/category_unit_management_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/create_unit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/edit_unit_screen.dart';

class UnitListScreen extends ConsumerWidget {
  const UnitListScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(unitListViewModelProvider).fetchUnits();
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    int unitId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Unit'),
        content: const Text('Are you sure you want to delete this unit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final vm = ref.read(unitListViewModelProvider);
    await vm.deleteUnit(unitId);

    if (!context.mounted) return;
    if (vm.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(unitListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const CreateUnitScreen()),
              );
              if (result == true) {
                await _refresh(ref);
              }
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Unit',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: vm.searchUnit,
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (vm.isLoading && vm.units.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (vm.error != null && vm.units.isEmpty) {
                        return Center(child: Text(vm.error!));
                      }
                      if (vm.filtered.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No units found')),
                          ],
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: vm.filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final unit = vm.filtered[index];
                          return ListTile(
                            title: Text(unit.name),
                            subtitle: Text(
                              unit.abbreviation?.trim().isNotEmpty == true
                                  ? unit.abbreviation!
                                  : 'No abbreviation',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    final result = await Navigator.of(context)
                                        .push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditUnitScreen(unitId: unit.id),
                                          ),
                                        );
                                    if (result == true) {
                                      await _refresh(ref);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _showDeleteDialog(context, ref, unit.id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
