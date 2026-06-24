import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/recipe_repository.dart';
import '../../../inventory/providers/inventory_provider.dart';

class IngredientListEditor extends ConsumerStatefulWidget {
  final List<IngredientInput> ingredients;
  final ValueChanged<List<IngredientInput>> onChanged;

  const IngredientListEditor({
    super.key,
    required this.ingredients,
    required this.onChanged,
  });

  @override
  ConsumerState<IngredientListEditor> createState() =>
      _IngredientListEditorState();
}

class _IngredientListEditorState extends ConsumerState<IngredientListEditor> {
  static const _unitOptions = [
    'item', 'cup', 'tbsp', 'tsp', 'oz', 'lb', 'g', 'kg', 'ml', 'liter',
    'piece', 'slice', 'clove', 'pinch', 'can', 'bottle', 'bag', 'box',
  ];

  void _addIngredient() {
    widget.onChanged([
      ...widget.ingredients,
      IngredientInput(name: '', quantity: 1.0, unit: 'item'),
    ]);
  }

  void _removeIngredient(int index) {
    final updated = [...widget.ingredients]..removeAt(index);
    widget.onChanged(updated);
  }

  void _updateIngredient(int index, IngredientInput updated) {
    final list = [...widget.ingredients];
    list[index] = updated;
    widget.onChanged(list);
  }

  void _showItemPicker(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, dialogRef, _) {
          final itemsAsync = dialogRef.watch(inventoryStreamProvider);
          return AlertDialog(
            title: const Text('Link to Inventory Item'),
            contentPadding: const EdgeInsets.only(top: 12),
            content: SizedBox(
              width: 340,
              child: itemsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $e'),
                ),
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No items in inventory'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return ListTile(
                              leading: const Icon(Icons.link_off),
                              title: const Text('No link (free-text)'),
                              onTap: () {
                                _updateIngredient(
                                  index,
                                  IngredientInput(
                                    inventoryItemId: null,
                                    name: widget.ingredients[index].name,
                                    quantity:
                                        widget.ingredients[index].quantity,
                                    unit: widget.ingredients[index].unit,
                                  ),
                                );
                                Navigator.of(ctx).pop();
                              },
                            );
                          }
                          final item = items[i - 1].item;
                          return ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text(item.name),
                            subtitle: Text(
                                '${item.quantity} ${item.unit}s in stock'),
                            onTap: () {
                              _updateIngredient(
                                index,
                                IngredientInput(
                                  inventoryItemId: item.id,
                                  name: item.name,
                                  quantity:
                                      widget.ingredients[index].quantity,
                                  unit: widget.ingredients[index].unit,
                                ),
                              );
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Ingredients', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        if (widget.ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('No ingredients added yet',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5))),
            ),
          ),
        ...List.generate(widget.ingredients.length, (index) {
          final ing = widget.ingredients[index];
          return Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: ing.name,
                          decoration: InputDecoration(
                            labelText: 'Ingredient name',
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                ing.inventoryItemId != null
                                    ? Icons.link
                                    : Icons.link_off,
                                size: 18,
                                color: ing.inventoryItemId != null
                                    ? colorScheme.primary
                                    : null,
                              ),
                              tooltip: 'Link to inventory item',
                              onPressed: () => _showItemPicker(index),
                            ),
                          ),
                          onChanged: (v) => _updateIngredient(
                            index,
                            IngredientInput(
                              inventoryItemId: ing.inventoryItemId,
                              name: v,
                              quantity: ing.quantity,
                              unit: ing.unit,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeIngredient(index),
                        icon: Icon(Icons.remove_circle,
                            color: colorScheme.error, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: ing.quantity.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Qty',
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (v) => _updateIngredient(
                            index,
                            IngredientInput(
                              inventoryItemId: ing.inventoryItemId,
                              name: ing.name,
                              quantity: double.tryParse(v) ?? 1.0,
                              unit: ing.unit,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: ing.unit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            isDense: true,
                          ),
                          items: _unitOptions
                              .map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ))
                              .toList(),
                          onChanged: (v) => _updateIngredient(
                            index,
                            IngredientInput(
                              inventoryItemId: ing.inventoryItemId,
                              name: ing.name,
                              quantity: ing.quantity,
                              unit: v ?? 'item',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
