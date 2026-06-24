import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class RecipeWithIngredients {
  final Recipe recipe;
  final List<RecipeIngredient> ingredients;

  RecipeWithIngredients({required this.recipe, required this.ingredients});

  List<String> get tagsList =>
      (jsonDecode(recipe.tags) as List).cast<String>();

  String get totalTimeDisplay {
    final prep = recipe.prepTimeMinutes ?? 0;
    final cook = recipe.cookTimeMinutes ?? 0;
    final total = prep + cook;
    if (total == 0) return '';
    if (total < 60) return '${total}min';
    final hours = total ~/ 60;
    final mins = total % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

class RecipeRepository {
  final AppDatabase _db;

  RecipeRepository(this._db);

  Stream<List<RecipeWithIngredients>> watchAllRecipes() {
    final recipesQuery = _db.select(_db.recipes)
      ..orderBy([(r) => OrderingTerm.asc(r.name)]);

    return recipesQuery.watch().asyncMap((recipes) async {
      final allIngredients = await _db.select(_db.recipeIngredients).get();
      final ingredientsByRecipe = <int, List<RecipeIngredient>>{};
      for (final ing in allIngredients) {
        ingredientsByRecipe.putIfAbsent(ing.recipeId, () => []).add(ing);
      }
      return recipes
          .map((recipe) => RecipeWithIngredients(
                recipe: recipe,
                ingredients: ingredientsByRecipe[recipe.id] ?? [],
              ))
          .toList();
    });
  }

  Stream<RecipeWithIngredients> watchRecipeById(int id) {
    final query = _db.select(_db.recipes)..where((r) => r.id.equals(id));

    return query.watchSingle().asyncMap((recipe) async {
      final ingredients = await (_db.select(_db.recipeIngredients)
            ..where((i) => i.recipeId.equals(id)))
          .get();
      return RecipeWithIngredients(recipe: recipe, ingredients: ingredients);
    });
  }

  Future<RecipeWithIngredients> getRecipeById(int id) async {
    final recipe = await (_db.select(_db.recipes)
          ..where((r) => r.id.equals(id)))
        .getSingle();
    final ingredients = await (_db.select(_db.recipeIngredients)
          ..where((i) => i.recipeId.equals(id)))
        .get();
    return RecipeWithIngredients(recipe: recipe, ingredients: ingredients);
  }

  Future<int> insertRecipe({
    required String name,
    String? description,
    required String instructions,
    int servings = 1,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String difficulty = 'easy',
    List<String> tags = const [],
    String? imageUrl,
    required List<IngredientInput> ingredients,
  }) async {
    return _db.transaction(() async {
      final recipeId =
          await _db.into(_db.recipes).insert(RecipesCompanion.insert(
                name: name,
                description: Value(description),
                instructions: instructions,
                servings: Value(servings),
                prepTimeMinutes: Value(prepTimeMinutes),
                cookTimeMinutes: Value(cookTimeMinutes),
                difficulty: Value(difficulty),
                tags: Value(jsonEncode(tags)),
                imageUrl: Value(imageUrl),
              ));

      for (final ing in ingredients) {
        await _db
            .into(_db.recipeIngredients)
            .insert(RecipeIngredientsCompanion.insert(
              recipeId: recipeId,
              inventoryItemId: Value(ing.inventoryItemId),
              name: ing.name,
              quantity: Value(ing.quantity),
              unit: Value(ing.unit),
            ));
      }

      return recipeId;
    });
  }

  Future<void> updateRecipe({
    required int id,
    required String name,
    String? description,
    required String instructions,
    int servings = 1,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String difficulty = 'easy',
    List<String> tags = const [],
    String? imageUrl,
    required List<IngredientInput> ingredients,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
        RecipesCompanion(
          name: Value(name),
          description: Value(description),
          instructions: Value(instructions),
          servings: Value(servings),
          prepTimeMinutes: Value(prepTimeMinutes),
          cookTimeMinutes: Value(cookTimeMinutes),
          difficulty: Value(difficulty),
          tags: Value(jsonEncode(tags)),
          imageUrl: Value(imageUrl),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Delete old ingredients and re-insert
      await (_db.delete(_db.recipeIngredients)
            ..where((i) => i.recipeId.equals(id)))
          .go();

      for (final ing in ingredients) {
        await _db
            .into(_db.recipeIngredients)
            .insert(RecipeIngredientsCompanion.insert(
              recipeId: id,
              inventoryItemId: Value(ing.inventoryItemId),
              name: ing.name,
              quantity: Value(ing.quantity),
              unit: Value(ing.unit),
            ));
      }
    });
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await (_db.update(_db.recipes)..where((r) => r.id.equals(id)))
        .write(RecipesCompanion(isFavorite: Value(isFavorite)));
  }

  Future<int> deleteRecipe(int id) {
    return (_db.delete(_db.recipes)..where((r) => r.id.equals(id))).go();
  }

  Stream<List<RecipeWithAvailability>> watchRecipesWithAvailability() {
    return watchAllRecipes().asyncMap((recipes) async {
      final inventoryItems = await _db.select(_db.inventoryItems).get();
      final itemMap = {for (final i in inventoryItems) i.id: i};

      return recipes.map((rw) {
        return _computeAvailability(rw, itemMap);
      }).toList();
    });
  }

  Stream<List<RecipeWithAvailability>> watchMealSuggestions() {
    return watchRecipesWithAvailability().map((recipes) {
      final suggestions = recipes
          .where((r) =>
              r.status == RecipeAvailability.ready ||
              r.status == RecipeAvailability.almostReady ||
              r.urgencyScore > 0)
          .toList()
        ..sort((a, b) {
          final urgencyCompare = b.urgencyScore.compareTo(a.urgencyScore);
          if (urgencyCompare != 0) return urgencyCompare;
          final statusCompare =
              a.status.index.compareTo(b.status.index);
          if (statusCompare != 0) return statusCompare;
          return a.recipe.name.compareTo(b.recipe.name);
        });
      return suggestions;
    });
  }

  RecipeWithAvailability _computeAvailability(
      RecipeWithIngredients rw, Map<int, InventoryItem> itemMap) {
    final ingredientAvailabilities = <IngredientAvailability>[];
    int missingCount = 0;
    int linkedCount = 0;
    DateTime? soonestExpiration;
    int urgencyScore = 0;

    for (final ing in rw.ingredients) {
      if (ing.inventoryItemId == null) {
        ingredientAvailabilities.add(IngredientAvailability(
          ingredient: ing,
          status: IngredientStatus.untracked,
        ));
        continue;
      }

      linkedCount++;
      final item = itemMap[ing.inventoryItemId];

      if (item == null) {
        missingCount++;
        ingredientAvailabilities.add(IngredientAvailability(
          ingredient: ing,
          status: IngredientStatus.missing,
        ));
        continue;
      }

      final available = item.quantity.toDouble();
      IngredientStatus status;
      if (available >= ing.quantity) {
        status = IngredientStatus.inStock;
      } else if (available > 0) {
        status = IngredientStatus.partial;
        missingCount++;
      } else {
        status = IngredientStatus.missing;
        missingCount++;
      }

      ingredientAvailabilities.add(IngredientAvailability(
        ingredient: ing,
        inventoryItem: item,
        status: status,
        availableQuantity: available,
      ));

      // Compute expiration urgency
      if (item.expirationDate != null && available > 0) {
        final daysLeft =
            item.expirationDate!.difference(DateTime.now()).inDays;
        if (daysLeft <= 7) {
          final score = (8 - daysLeft).clamp(0, 8);
          if (score > urgencyScore) urgencyScore = score;
          if (soonestExpiration == null ||
              item.expirationDate!.isBefore(soonestExpiration)) {
            soonestExpiration = item.expirationDate;
          }
        }
      }
    }

    RecipeAvailability status;
    if (linkedCount == 0) {
      status = RecipeAvailability.noLinkedIngredients;
    } else if (missingCount == 0) {
      status = RecipeAvailability.ready;
    } else if (missingCount <= 2) {
      status = RecipeAvailability.almostReady;
    } else {
      status = RecipeAvailability.needsItems;
    }

    return RecipeWithAvailability(
      recipe: rw.recipe,
      ingredients: ingredientAvailabilities,
      status: status,
      missingCount: missingCount,
      urgencyScore: urgencyScore,
      soonestExpiration: soonestExpiration,
      tags: rw.tagsList,
      totalTimeDisplay: rw.totalTimeDisplay,
    );
  }

  Stream<List<RecipeWithIngredients>> watchFavoriteRecipes() {
    final query = _db.select(_db.recipes)
      ..where((r) => r.isFavorite.equals(true))
      ..orderBy([(r) => OrderingTerm.asc(r.name)]);

    return query.watch().asyncMap((recipes) async {
      final allIngredients = await _db.select(_db.recipeIngredients).get();
      final ingredientsByRecipe = <int, List<RecipeIngredient>>{};
      for (final ing in allIngredients) {
        ingredientsByRecipe.putIfAbsent(ing.recipeId, () => []).add(ing);
      }
      return recipes
          .map((recipe) => RecipeWithIngredients(
                recipe: recipe,
                ingredients: ingredientsByRecipe[recipe.id] ?? [],
              ))
          .toList();
    });
  }
}

enum RecipeAvailability { ready, almostReady, needsItems, noLinkedIngredients }

enum IngredientStatus { inStock, partial, missing, untracked }

class IngredientAvailability {
  final RecipeIngredient ingredient;
  final InventoryItem? inventoryItem;
  final IngredientStatus status;
  final double availableQuantity;

  IngredientAvailability({
    required this.ingredient,
    this.inventoryItem,
    required this.status,
    this.availableQuantity = 0,
  });
}

class RecipeWithAvailability {
  final Recipe recipe;
  final List<IngredientAvailability> ingredients;
  final RecipeAvailability status;
  final int missingCount;
  final int urgencyScore;
  final DateTime? soonestExpiration;
  final List<String> tags;
  final String totalTimeDisplay;

  RecipeWithAvailability({
    required this.recipe,
    required this.ingredients,
    required this.status,
    required this.missingCount,
    required this.urgencyScore,
    this.soonestExpiration,
    required this.tags,
    required this.totalTimeDisplay,
  });
}

class IngredientInput {
  final int? inventoryItemId;
  final String name;
  final double quantity;
  final String unit;

  IngredientInput({
    this.inventoryItemId,
    required this.name,
    this.quantity = 1.0,
    this.unit = 'item',
  });
}
