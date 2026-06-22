// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryRepositoryHash() =>
    r'90d7aaef23687bc55a28ba72de48b734eff8ff99';

/// See also [inventoryRepository].
@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider =
    AutoDisposeProvider<InventoryRepository>.internal(
      inventoryRepository,
      name: r'inventoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryRepositoryRef = AutoDisposeProviderRef<InventoryRepository>;
String _$inventoryStreamHash() => r'5dfd660a1aa47e7127edff159d514a8e12708573';

/// See also [inventoryStream].
@ProviderFor(inventoryStream)
final inventoryStreamProvider =
    AutoDisposeStreamProvider<List<InventoryItemWithCategories>>.internal(
      inventoryStream,
      name: r'inventoryStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryStreamRef =
    AutoDisposeStreamProviderRef<List<InventoryItemWithCategories>>;
String _$inventoryItemByIdHash() => r'3be37ad2aaffcb701c5fad2a15ac79231f292551';

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

/// See also [inventoryItemById].
@ProviderFor(inventoryItemById)
const inventoryItemByIdProvider = InventoryItemByIdFamily();

/// See also [inventoryItemById].
class InventoryItemByIdFamily
    extends Family<AsyncValue<InventoryItemWithCategories>> {
  /// See also [inventoryItemById].
  const InventoryItemByIdFamily();

  /// See also [inventoryItemById].
  InventoryItemByIdProvider call(int id) {
    return InventoryItemByIdProvider(id);
  }

  @override
  InventoryItemByIdProvider getProviderOverride(
    covariant InventoryItemByIdProvider provider,
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
  String? get name => r'inventoryItemByIdProvider';
}

/// See also [inventoryItemById].
class InventoryItemByIdProvider
    extends AutoDisposeStreamProvider<InventoryItemWithCategories> {
  /// See also [inventoryItemById].
  InventoryItemByIdProvider(int id)
    : this._internal(
        (ref) => inventoryItemById(ref as InventoryItemByIdRef, id),
        from: inventoryItemByIdProvider,
        name: r'inventoryItemByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$inventoryItemByIdHash,
        dependencies: InventoryItemByIdFamily._dependencies,
        allTransitiveDependencies:
            InventoryItemByIdFamily._allTransitiveDependencies,
        id: id,
      );

  InventoryItemByIdProvider._internal(
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
    Stream<InventoryItemWithCategories> Function(InventoryItemByIdRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InventoryItemByIdProvider._internal(
        (ref) => create(ref as InventoryItemByIdRef),
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
  AutoDisposeStreamProviderElement<InventoryItemWithCategories>
  createElement() {
    return _InventoryItemByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryItemByIdProvider && other.id == id;
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
mixin InventoryItemByIdRef
    on AutoDisposeStreamProviderRef<InventoryItemWithCategories> {
  /// The parameter `id` of this provider.
  int get id;
}

class _InventoryItemByIdProviderElement
    extends AutoDisposeStreamProviderElement<InventoryItemWithCategories>
    with InventoryItemByIdRef {
  _InventoryItemByIdProviderElement(super.provider);

  @override
  int get id => (origin as InventoryItemByIdProvider).id;
}

String _$filteredInventoryHash() => r'ece63be070a9461cfc3f8ad0cf3d8b8c50a96ebf';

/// See also [filteredInventory].
@ProviderFor(filteredInventory)
final filteredInventoryProvider =
    AutoDisposeStreamProvider<List<InventoryItemWithCategories>>.internal(
      filteredInventory,
      name: r'filteredInventoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredInventoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredInventoryRef =
    AutoDisposeStreamProviderRef<List<InventoryItemWithCategories>>;
String _$selectedCategoryFilterHash() =>
    r'b8ca58a048c55b9d277eab516faae832ab3af9af';

/// See also [SelectedCategoryFilter].
@ProviderFor(SelectedCategoryFilter)
final selectedCategoryFilterProvider =
    AutoDisposeNotifierProvider<SelectedCategoryFilter, Set<int>>.internal(
      SelectedCategoryFilter.new,
      name: r'selectedCategoryFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCategoryFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCategoryFilter = AutoDisposeNotifier<Set<int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
