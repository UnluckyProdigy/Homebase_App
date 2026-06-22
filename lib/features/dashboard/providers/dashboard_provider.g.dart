// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardSettingsRepositoryHash() =>
    r'84d0a6ef1a4f9d612bd5efbf7d618b305f210f14';

/// See also [dashboardSettingsRepository].
@ProviderFor(dashboardSettingsRepository)
final dashboardSettingsRepositoryProvider =
    AutoDisposeProvider<DashboardSettingsRepository>.internal(
      dashboardSettingsRepository,
      name: r'dashboardSettingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardSettingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardSettingsRepositoryRef =
    AutoDisposeProviderRef<DashboardSettingsRepository>;
String _$lowStockItemsHash() => r'f2f257ce1f6867129c61565f05b39eff133b3b51';

/// See also [lowStockItems].
@ProviderFor(lowStockItems)
final lowStockItemsProvider =
    AutoDisposeStreamProvider<List<InventoryItemWithCategories>>.internal(
      lowStockItems,
      name: r'lowStockItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lowStockItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LowStockItemsRef =
    AutoDisposeStreamProviderRef<List<InventoryItemWithCategories>>;
String _$expiringSoonItemsHash() => r'cccc575a1e323454ccdec662f0a42564af4656da';

/// See also [expiringSoonItems].
@ProviderFor(expiringSoonItems)
final expiringSoonItemsProvider =
    AutoDisposeStreamProvider<List<InventoryItemWithCategories>>.internal(
      expiringSoonItems,
      name: r'expiringSoonItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expiringSoonItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpiringSoonItemsRef =
    AutoDisposeStreamProviderRef<List<InventoryItemWithCategories>>;
String _$allInventoryItemsHash() => r'50ed125eece344314377935148551aa0af18616e';

/// See also [allInventoryItems].
@ProviderFor(allInventoryItems)
final allInventoryItemsProvider =
    AutoDisposeStreamProvider<List<InventoryItemWithCategories>>.internal(
      allInventoryItems,
      name: r'allInventoryItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allInventoryItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllInventoryItemsRef =
    AutoDisposeStreamProviderRef<List<InventoryItemWithCategories>>;
String _$dashboardSectionsHash() => r'5c93009f19d004d1d87ed243ba9f0f5882540c69';

/// See also [DashboardSections].
@ProviderFor(DashboardSections)
final dashboardSectionsProvider =
    AutoDisposeAsyncNotifierProvider<
      DashboardSections,
      List<DashboardSection>
    >.internal(
      DashboardSections.new,
      name: r'dashboardSectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardSectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardSections = AutoDisposeAsyncNotifier<List<DashboardSection>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
