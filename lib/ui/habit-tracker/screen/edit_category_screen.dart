import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/provider/category_unit_management_provider.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final int categoryId;

  const EditCategoryScreen({super.key, required this.categoryId});

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final vm = ref.read(editCategoryViewModelProvider);
    await vm.loadDetail(widget.categoryId);
    if (!mounted) return;
    if (vm.category != null) {
      _nameController.text = vm.category!.name;
      _descriptionController.text = vm.category!.description ?? '';
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final vm = ref.read(editCategoryViewModelProvider);
    final success = await vm.submitUpdate(
      id: widget.categoryId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    setState(() => _submitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vm.error ?? 'Failed to update category')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(editCategoryViewModelProvider);

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Category')),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return vm.isLoading && vm.category == null
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
                              return 'Category name is required';
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
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return null;
                            if (text.length < 3) {
                              return 'Minimum 3 characters';
                            }
                            if (text.length > 255) {
                              return 'Maximum 255 characters';
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
                              : const Text('Update Category'),
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
