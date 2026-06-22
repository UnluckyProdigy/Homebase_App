// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertRepositoryHash() => r'7f2e1a231e58a2da11969811db7e4549819425ac';

/// See also [alertRepository].
@ProviderFor(alertRepository)
final alertRepositoryProvider = AutoDisposeProvider<AlertRepository>.internal(
  alertRepository,
  name: r'alertRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlertRepositoryRef = AutoDisposeProviderRef<AlertRepository>;
String _$alertsStreamHash() => r'fa308822248d18fa4341862c06a0e866eb3a8d56';

/// See also [alertsStream].
@ProviderFor(alertsStream)
final alertsStreamProvider =
    AutoDisposeStreamProvider<List<AlertWithItem>>.internal(
      alertsStream,
      name: r'alertsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlertsStreamRef = AutoDisposeStreamProviderRef<List<AlertWithItem>>;
String _$unreadAlertCountHash() => r'09edf80666416c89c1f20b3115f85cc9e6a1a1b8';

/// See also [unreadAlertCount].
@ProviderFor(unreadAlertCount)
final unreadAlertCountProvider = AutoDisposeStreamProvider<int>.internal(
  unreadAlertCount,
  name: r'unreadAlertCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadAlertCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadAlertCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
