// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeRepositoryHash() => r'9f287dd6fa7f871927aca876f947a7904e3ee974';

/// See also [recipeRepository].
@ProviderFor(recipeRepository)
final recipeRepositoryProvider = AutoDisposeProvider<RecipeRepository>.internal(
  recipeRepository,
  name: r'recipeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeRepositoryRef = AutoDisposeProviderRef<RecipeRepository>;
String _$recipeStreamHash() => r'472040254a9d04ed6f130e9017a8b8de53f9d02b';

/// See also [recipeStream].
@ProviderFor(recipeStream)
final recipeStreamProvider =
    AutoDisposeStreamProvider<List<RecipeWithIngredients>>.internal(
      recipeStream,
      name: r'recipeStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipeStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeStreamRef =
    AutoDisposeStreamProviderRef<List<RecipeWithIngredients>>;
String _$recipeByIdHash() => r'00d364c59373bdaf3f55bd9945c66bfb6d87d357';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recipeById].
@ProviderFor(recipeById)
const recipeByIdProvider = RecipeByIdFamily();

/// See also [recipeById].
class RecipeByIdFamily extends Family<AsyncValue<RecipeWithIngredients>> {
  /// See also [recipeById].
  const RecipeByIdFamily();

  /// See also [recipeById].
  RecipeByIdProvider call(int id) {
    return RecipeByIdProvider(id);
  }

  @override
  RecipeByIdProvider getProviderOverride(
    covariant RecipeByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipeByIdProvider';
}

/// See also [recipeById].
class RecipeByIdProvider
    extends AutoDisposeStreamProvider<RecipeWithIngredients> {
  /// See also [recipeById].
  RecipeByIdProvider(int id)
    : this._internal(
        (ref) => recipeById(ref as RecipeByIdRef, id),
        from: recipeByIdProvider,
        name: r'recipeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeByIdHash,
        dependencies: RecipeByIdFamily._dependencies,
        allTransitiveDependencies: RecipeByIdFamily._allTransitiveDependencies,
        id: id,
      );

  RecipeByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<RecipeWithIngredients> Function(RecipeByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecipeByIdProvider._internal(
        (ref) => create(ref as RecipeByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<RecipeWithIngredients> createElement() {
    return _RecipeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipeByIdRef on AutoDisposeStreamProviderRef<RecipeWithIngredients> {
  /// The parameter `id` of this provider.
  int get id;
}

class _RecipeByIdProviderElement
    extends AutoDisposeStreamProviderElement<RecipeWithIngredients>
    with RecipeByIdRef {
  _RecipeByIdProviderElement(super.provider);

  @override
  int get id => (origin as RecipeByIdProvider).id;
}

String _$favoriteRecipesHash() => r'16a2797c4d8173a0edb270d7d04b4be037a32acb';

/// See also [favoriteRecipes].
@ProviderFor(favoriteRecipes)
final favoriteRecipesProvider =
    AutoDisposeStreamProvider<List<RecipeWithIngredients>>.internal(
      favoriteRecipes,
      name: r'favoriteRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteRecipesRef =
    AutoDisposeStreamProviderRef<List<RecipeWithIngredients>>;
String _$recipesWithAvailabilityHash() =>
    r'aeab672e8e516049c88faaa9904f50d4bf881f35';

/// See also [recipesWithAvailability].
@ProviderFor(recipesWithAvailability)
final recipesWithAvailabilityProvider =
    AutoDisposeStreamProvider<List<RecipeWithAvailability>>.internal(
      recipesWithAvailability,
      name: r'recipesWithAvailabilityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipesWithAvailabilityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipesWithAvailabilityRef =
    AutoDisposeStreamProviderRef<List<RecipeWithAvailability>>;
String _$mealSuggestionsHash() => r'708a9d0af989edb60ba3cd992c315715a437ec58';

/// See also [mealSuggestions].
@ProviderFor(mealSuggestions)
final mealSuggestionsProvider =
    AutoDisposeStreamProvider<List<RecipeWithAvailability>>.internal(
      mealSuggestions,
      name: r'mealSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MealSuggestionsRef =
    AutoDisposeStreamProviderRef<List<RecipeWithAvailability>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
