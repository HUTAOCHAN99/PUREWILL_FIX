import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/provider/category_unit_management_provider.dart';

class CreateUnitScreen extends ConsumerStatefulWidget {
  const CreateUnitScreen({super.key});

  @override
  ConsumerState<CreateUnitScreen> createState() => _CreateUnitScreenState();
}

class _CreateUnitScreenState extends ConsumerState<CreateUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final vm = ref.read(createUnitViewModelProvider);
    final success = await vm.submitCreate(
      name: _nameController.text.trim(),
      abbreviation: _abbreviationController.text.trim().isEmpty
          ? null
          : _abbreviationController.text.trim(),
    );
    setState(() => _submitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit created successfully')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vm.error ?? 'Failed to create unit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(createUnitViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Unit')),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return Padding(
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
                      if (text.length < 1) {
                        return 'Minimum 1 character';
                      }
                      if (text.length > 50) {
                        return 'Maximum 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting || vm.isLoading ? null : _submit,
                    child: _submitting || vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Unit'),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 16),
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
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
