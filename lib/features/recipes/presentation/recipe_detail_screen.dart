import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../inventory/providers/inventory_provider.dart';
import '../data/recipe_repository.dart';
import '../providers/recipe_provider.dart';
import 'widgets/availability_badge.dart';
import 'widgets/ingredient_availability_tile.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));
    final availabilityAsync = ref.watch(recipesWithAvailabilityProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return recipeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (rw) {
        final recipe = rw.recipe;

        // Find availability data for this recipe
        final rwa = availabilityAsync.valueOrNull
            ?.where((r) => r.recipe.id == recipeId)
            .firstOrNull;

        final difficultyColor = switch (recipe.difficulty) {
          'easy' => Colors.green,
          'medium' => Colors.orange,
          'hard' => Colors.red,
          _ => Colors.grey,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.name),
            actions: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.red : null,
                ),
                onPressed: () => ref
                    .read(recipeRepositoryProvider)
                    .toggleFavorite(recipe.id, !recipe.isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/recipes/edit/${recipe.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Recipe'),
                      content: Text(
                          'Delete "${recipe.name}"? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(recipeRepositoryProvider)
                        .deleteRecipe(recipe.id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.difficulty[0].toUpperCase() +
                          recipe.difficulty.substring(1),
                      style: TextStyle(
                          color: difficultyColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (rw.totalTimeDisplay.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.schedule,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(rw.totalTimeDisplay,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                  const SizedBox(width: 12),
                  Icon(Icons.restaurant,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                      '${recipe.servings} serving${recipe.servings == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey[600])),
                  if (rwa != null) ...[
                    const Spacer(),
                    AvailabilityBadge(
                      status: rwa.status,
                      missingCount: rwa.missingCount,
                    ),
                  ],
                ],
              ),

              if (recipe.description != null &&
                  recipe.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(recipe.description!,
                    style: Theme.of(context).textTheme.bodyLarge),
              ],

              // Tags
              if (rw.tagsList.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: rw.tagsList
                      .map((tag) => Chip(
                            label: Text(tag,
                                style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Ingredients with availability
              if (rw.ingredients.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ingredients',
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (rwa != null)
                          ...rwa.ingredients.map(
                              (ia) => IngredientAvailabilityTile(
                                  availability: ia))
                        else
                          ...rw.ingredients.map((ing) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      ing.inventoryItemId != null
                                          ? Icons.inventory_2
                                          : Icons.circle,
                                      size: ing.inventoryItemId != null
                                          ? 16
                                          : 6,
                                      color: ing.inventoryItemId != null
                                          ? colorScheme.primary
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_formatQuantity(ing.quantity)} ${ing.unit}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(ing.name)),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Cook This button
              if (rwa != null &&
                  rwa.status == RecipeAvailability.ready &&
                  rwa.ingredients.any(
                      (i) => i.status == IngredientStatus.inStock)) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showCookDialog(context, ref, rwa),
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Cook This'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instructions',
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(recipe.instructions,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),

              // Time breakdown
              if (recipe.prepTimeMinutes != null ||
                  recipe.cookTimeMinutes != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (recipe.prepTimeMinutes != null)
                          _timeColumn(context, 'Prep',
                              recipe.prepTimeMinutes!),
                        if (recipe.cookTimeMinutes != null)
                          _timeColumn(context, 'Cook',
                              recipe.cookTimeMinutes!),
                        if (recipe.prepTimeMinutes != null &&
                            recipe.cookTimeMinutes != null)
                          _timeColumn(
                              context,
                              'Total',
                              recipe.prepTimeMinutes! +
                                  recipe.cookTimeMinutes!),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCookDialog(
      BuildContext context, WidgetRef ref, RecipeWithAvailability rwa) async {
    final linkedIngredients = rwa.ingredients
        .where((i) =>
            i.status == IngredientStatus.inStock &&
            i.inventoryItem != null)
        .toList();

    if (linkedIngredients.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cook This Recipe?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following items will be decremented from your inventory:'),
            const SizedBox(height: 12),
            ...linkedIngredients.map((ia) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                      '  - ${_formatQuantity(ia.ingredient.quantity)} ${ia.ingredient.unit} of ${ia.ingredient.name}'),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.restaurant),
            label: const Text('Cook'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(inventoryRepositoryProvider);
      for (final ia in linkedIngredients) {
        final newQty =
            (ia.inventoryItem!.quantity - ia.ingredient.quantity.ceil())
                .clamp(0, ia.inventoryItem!.quantity);
        await repo.updateQuantity(ia.inventoryItem!.id, newQty);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${rwa.recipe.name} cooked! Inventory updated.')),
        );
      }
    }
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  Widget _timeColumn(BuildContext context, String label, int minutes) {
    final display = minutes < 60
        ? '${minutes}m'
        : '${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}';
    return Column(
      children: [
        Text(display,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
