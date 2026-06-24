import 'package:flutter/material.dart';

import '../../data/recipe_repository.dart';

class IngredientAvailabilityTile extends StatelessWidget {
  final IngredientAvailability availability;

  const IngredientAvailabilityTile({
    super.key,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final ing = availability.ingredient;
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, color) = switch (availability.status) {
      IngredientStatus.inStock => (Icons.check_circle, Colors.green),
      IngredientStatus.partial => (Icons.warning_amber, Colors.orange),
      IngredientStatus.missing => (Icons.cancel, colorScheme.error),
      IngredientStatus.untracked => (Icons.circle, Colors.grey),
    };

    final qtyText = _formatQuantity(ing.quantity);
    String subtitle = '$qtyText ${ing.unit}';
    if (availability.status == IngredientStatus.partial) {
      subtitle +=
          ' (have ${_formatQuantity(availability.availableQuantity)})';
    } else if (availability.status == IngredientStatus.missing &&
        availability.inventoryItem != null) {
      subtitle += ' (out of stock)';
    } else if (availability.status == IngredientStatus.missing &&
        availability.inventoryItem == null &&
        ing.inventoryItemId != null) {
      subtitle += ' (item deleted)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }
}
