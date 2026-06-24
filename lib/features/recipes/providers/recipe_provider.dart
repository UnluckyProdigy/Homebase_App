import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../data/recipe_repository.dart';

part 'recipe_provider.g.dart';

@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  return RecipeRepository(database);
}

@riverpod
Stream<List<RecipeWithIngredients>> recipeStream(RecipeStreamRef ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchAllRecipes();
}

@riverpod
Stream<RecipeWithIngredients> recipeById(RecipeByIdRef ref, int id) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchRecipeById(id);
}

@riverpod
Stream<List<RecipeWithIngredients>> favoriteRecipes(
    FavoriteRecipesRef ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchFavoriteRecipes();
}

@riverpod
Stream<List<RecipeWithAvailability>> recipesWithAvailability(
    RecipesWithAvailabilityRef ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchRecipesWithAvailability();
}

@riverpod
Stream<List<RecipeWithAvailability>> mealSuggestions(
    MealSuggestionsRef ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchMealSuggestions();
}
