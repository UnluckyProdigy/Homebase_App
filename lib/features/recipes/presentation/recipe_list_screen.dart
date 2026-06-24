import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/recipe_provider.dart';
import 'widgets/recipe_card.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Meal Suggestions',
            onPressed: () => context.push('/recipes/suggestions'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recipes/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (recipes) {
                final filtered = _searchQuery.isEmpty
                    ? recipes
                    : recipes
                        .where((r) =>
                            r.recipe.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            r.tagsList.any((t) => t
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No recipes match "$_searchQuery"'
                              : 'No recipes yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Tap + to create your first recipe'),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return RecipeCard(
                      recipeWithIngredients: r,
                      onTap: () => context
                          .push('/recipes/detail/${r.recipe.id}'),
                      onFavoriteToggle: () => ref
                          .read(recipeRepositoryProvider)
                          .toggleFavorite(
                              r.recipe.id, !r.recipe.isFavorite),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
