import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/recipe_repository.dart';
import '../providers/recipe_provider.dart';
import 'widgets/availability_badge.dart';

class MealSuggestionsScreen extends ConsumerWidget {
  const MealSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(mealSuggestionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Suggestions')),
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No suggestions yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Add recipes with linked inventory ingredients\nto get meal suggestions',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final rwa = suggestions[index];
              return _SuggestionCard(recipeWithAvailability: rwa);
            },
          );
        },
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final RecipeWithAvailability recipeWithAvailability;

  const _SuggestionCard({required this.recipeWithAvailability});

  @override
  Widget build(BuildContext context) {
    final rwa = recipeWithAvailability;
    final recipe = rwa.recipe;
    final expiringIngredients = rwa.ingredients
        .where((i) =>
            i.inventoryItem?.expirationDate != null &&
            i.inventoryItem!.expirationDate!
                .difference(DateTime.now())
                .inDays <=
                7 &&
            i.status == IngredientStatus.inStock)
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () =>
            context.push('/recipes/detail/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(recipe.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  AvailabilityBadge(
                    status: rwa.status,
                    missingCount: rwa.missingCount,
                  ),
                ],
              ),
              if (rwa.totalTimeDisplay.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(rwa.totalTimeDisplay,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
              if (expiringIngredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Uses expiring: ${expiringIngredients.map((i) => i.ingredient.name).join(', ')}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
