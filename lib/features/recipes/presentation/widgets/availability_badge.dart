import 'package:flutter/material.dart';

import '../../data/recipe_repository.dart';

class AvailabilityBadge extends StatelessWidget {
  final RecipeAvailability status;
  final int missingCount;

  const AvailabilityBadge({
    super.key,
    required this.status,
    required this.missingCount,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RecipeAvailability.ready => ('Ready', Colors.green),
      RecipeAvailability.almostReady => ('Almost', Colors.orange),
      RecipeAvailability.needsItems => ('$missingCount needed', Colors.red),
      RecipeAvailability.noLinkedIngredients => ('No links', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == RecipeAvailability.ready
                ? Icons.check_circle
                : status == RecipeAvailability.almostReady
                    ? Icons.warning_amber
                    : status == RecipeAvailability.needsItems
                        ? Icons.cancel
                        : Icons.link_off,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
