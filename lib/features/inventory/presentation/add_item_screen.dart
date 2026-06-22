import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/icon_helper.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../categories/providers/categories_provider.dart';
import '../providers/inventory_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final int? editItemId;
  final String? prefilledBarcode;
  final String? prefilledName;
  final String? prefilledBrand;
  final String? prefilledImageUrl;

  const AddItemScreen({
    super.key,
    this.editItemId,
    this.prefilledBarcode,
    this.prefilledName,
    this.prefilledBrand,
    this.prefilledImageUrl,
  });

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _brandController;
  late final TextEditingController _notesController;

  Set<int> _selectedCategoryIds = {};
  int _quantity = 1;
  String _unit = 'item';
  bool _lowStockAlertEnabled = true;
  int _lowStockThreshold = 2;
  String _priority = 'normal';
  DateTime? _expirationDate;
  bool _initialized = false;

  bool get _isEditing => widget.editItemId != null;

  static const _unitOptions = [
    'item', 'box', 'bottle', 'bag', 'can', 'pack', 'lb', 'oz', 'gallon', 'liter',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.prefilledName ?? '');
    _descriptionController = TextEditingController();
    _brandController =
        TextEditingController(text: widget.prefilledBrand ?? '');
    _notesController = TextEditingController();
  }

  void _initFromItem(InventoryItem item) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _brandController.text = item.brand ?? '';
    _notesController.text = item.notes ?? '';
    _selectedCategoryIds =
        (jsonDecode(item.categoryIds) as List).cast<int>().toSet();
    _quantity = item.quantity;
    _unit = item.unit;
    _lowStockAlertEnabled = item.lowStockAlertEnabled;
    _lowStockThreshold = item.lowStockThreshold;
    _priority = item.priority;
    _expirationDate = item.expirationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  void _showCategoryPicker(List<Category> categories) {
    final sorted = [...categories]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select Categories'),
          contentPadding: const EdgeInsets.only(top: 12),
          content: SizedBox(
            width: 340,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sorted.length,
              itemBuilder: (ctx, index) {
                final c = sorted[index];
                final isSelected = _selectedCategoryIds.contains(c.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Row(
                    children: [
                      Icon(
                        IconHelper.getIcon(c.iconName),
                        color: IconHelper.parseColor(c.colorHex),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(c.name),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) {
                    setDialogState(() {
                      if (isSelected) {
                        _selectedCategoryIds.remove(c.id);
                      } else {
                        _selectedCategoryIds.add(c.id);
                      }
                    });
                    setState(() {});
                  },
                );
              },
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    final repo = ref.read(inventoryRepositoryProvider);

    if (_isEditing) {
      final item = (await repo.getItemById(widget.editItemId!)).item;
      await repo.updateItem(
        id: widget.editItemId!,
        barcode: item.barcode,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryIds: _selectedCategoryIds.toList(),
        quantity: _quantity,
        unit: _unit,
        imageUrl: item.imageUrl,
        lowStockAlertEnabled: _lowStockAlertEnabled,
        lowStockThreshold: _lowStockThreshold,
        priority: _priority,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        expirationDate: _expirationDate,
      );
    } else {
      await repo.insertItem(
        barcode: widget.prefilledBarcode,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryIds: _selectedCategoryIds.toList(),
        quantity: _quantity,
        unit: _unit,
        imageUrl: widget.prefilledImageUrl,
        lowStockAlertEnabled: _lowStockAlertEnabled,
        lowStockThreshold: _lowStockThreshold,
        priority: _priority,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        expirationDate: _expirationDate,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    // Load existing item data for editing
    if (_isEditing && !_initialized) {
      final itemAsync = ref.watch(inventoryItemByIdProvider(widget.editItemId!));
      itemAsync.whenData((ic) => _initFromItem(ic.item));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Category multi-select
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading categories: $e'),
              data: (categories) {
                final selectedNames = categories
                    .where((c) => _selectedCategoryIds.contains(c.id))
                    .map((c) => c.name)
                    .toList();

                return InkWell(
                  onTap: () => _showCategoryPicker(categories),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Categories *',
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: selectedNames.isEmpty
                              ? Text('Tap to select categories',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5)))
                              : Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: selectedNames
                                      .map((name) => Chip(
                                            label: Text(name,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quantity
            Text('Quantity', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                QuantityStepper(
                  quantity: _quantity,
                  onChanged: (v) => setState(() => _quantity = v),
                  min: 1,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _unitOptions
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'item'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Low stock threshold toggle
            SwitchListTile(
              title: const Text('Low Stock Alert'),
              subtitle: const Text('Get notified when running low'),
              value: _lowStockAlertEnabled,
              onChanged: (v) =>
                  setState(() => _lowStockAlertEnabled = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (_lowStockAlertEnabled) ...[
              const SizedBox(height: 8),
              Text('Alert Threshold',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              QuantityStepper(
                quantity: _lowStockThreshold,
                onChanged: (v) =>
                    setState(() => _lowStockThreshold = v),
              ),
              const SizedBox(height: 4),
              Text(
                'Alert when quantity drops to $_lowStockThreshold or below',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),

            // Priority
            SwitchListTile(
              title: const Text('Must-Have Item'),
              subtitle:
                  const Text('Higher priority alerts when running low'),
              value: _priority == 'must_have',
              onChanged: (v) => setState(
                  () => _priority = v ? 'must_have' : 'normal'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Expiration date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expiration Date'),
              subtitle: Text(
                _expirationDate != null
                    ? DateFormat.yMMMd().format(_expirationDate!)
                    : 'Not set',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expirationDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          setState(() => _expirationDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickExpirationDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _save,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label:
                  Text(_isEditing ? 'Save Changes' : 'Add to Inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
