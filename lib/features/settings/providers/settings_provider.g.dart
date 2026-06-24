// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigationSettingsRepositoryHash() =>
    r'1c91e6ae6b4037e1a328b1959a529850ab34e802';

/// See also [navigationSettingsRepository].
@ProviderFor(navigationSettingsRepository)
final navigationSettingsRepositoryProvider =
    AutoDisposeProvider<NavigationSettingsRepository>.internal(
      navigationSettingsRepository,
      name: r'navigationSettingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$navigationSettingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigationSettingsRepositoryRef =
    AutoDisposeProviderRef<NavigationSettingsRepository>;
String _$navigationTabsHash() => r'0f48ba8ad57e6b515c81878d546bf90daeadbff5';

/// See also [NavigationTabs].
@ProviderFor(NavigationTabs)
final navigationTabsProvider =
    AutoDisposeAsyncNotifierProvider<NavigationTabs, List<NavTab>>.internal(
      NavigationTabs.new,
      name: r'navigationTabsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$navigationTabsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NavigationTabs = AutoDisposeAsyncNotifier<List<NavTab>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
