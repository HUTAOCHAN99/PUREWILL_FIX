import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/provider/category_unit_management_provider.dart';

class EditUnitScreen extends ConsumerStatefulWidget {
  final int unitId;

  const EditUnitScreen({super.key, required this.unitId});

  @override
  ConsumerState<EditUnitScreen> createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends ConsumerState<EditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final vm = ref.read(editUnitViewModelProvider);
    await vm.loadDetail(widget.unitId);
    if (!mounted) return;
    if (vm.unit != null) {
      _nameController.text = vm.unit!.name;
      _abbreviationController.text = vm.unit!.abbreviation ?? '';
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final vm = ref.read(editUnitViewModelProvider);
    final success = await vm.submitUpdate(
      id: widget.unitId,
      name: _nameController.text.trim(),
      abbreviation: _abbreviationController.text.trim().isEmpty
          ? null
          : _abbreviationController.text.trim(),
    );
    setState(() => _submitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit updated successfully')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vm.error ?? 'Failed to update unit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(editUnitViewModelProvider);

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Unit')),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return vm.isLoading && vm.unit == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Unit name is required';
                            }
                            if (value.trim().length < 3) {
                              return 'Minimum 3 characters';
                            }
                            if (value.trim().length > 100) {
                              return 'Maximum 100 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _abbreviationController,
                          decoration: const InputDecoration(
                            labelText: 'Abbreviation',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return null;
                            if (text.length > 50) {
                              return 'Maximum 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _submitting || vm.isLoading
                              ? null
                              : _submit,
                          child: _submitting || vm.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Update Unit'),
                        ),
                        if (vm.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            vm.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
