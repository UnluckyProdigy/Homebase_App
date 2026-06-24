import 'package:flutter/material.dart';

import '../../data/recipe_repository.dart';

class RecipeCard extends StatelessWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipeWithIngredients,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recipeWithIngredients.recipe;
    final colorScheme = Theme.of(context).colorScheme;

    final difficultyColor = switch (recipe.difficulty) {
      'easy' => Colors.green,
      'medium' => Colors.orange,
      'hard' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      recipe.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: recipe.isFavorite ? Colors.red : null,
                    ),
                    iconSize: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(recipe.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.difficulty[0].toUpperCase() +
                          recipe.difficulty.substring(1),
                      style: TextStyle(
                          fontSize: 11,
                          color: difficultyColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (recipeWithIngredients.totalTimeDisplay.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(recipeWithIngredients.totalTimeDisplay,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                  const SizedBox(width: 8),
                  Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text('${recipe.servings} serving${recipe.servings == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (recipeWithIngredients.ingredients.isNotEmpty) ...[
                    const Spacer(),
                    Text(
                        '${recipeWithIngredients.ingredients.length} ingredient${recipeWithIngredients.ingredients.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ],
              ),
              if (recipeWithIngredients.tagsList.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recipeWithIngredients.tagsList
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tag,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7))),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
