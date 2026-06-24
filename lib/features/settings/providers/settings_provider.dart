import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../data/navigation_settings_repository.dart';

part 'settings_provider.g.dart';

@riverpod
NavigationSettingsRepository navigationSettingsRepository(
    NavigationSettingsRepositoryRef ref) {
  return NavigationSettingsRepository(database);
}

@riverpod
class NavigationTabs extends _$NavigationTabs {
  @override
  Future<List<NavTab>> build() async {
    final repo = ref.watch(navigationSettingsRepositoryProvider);
    return repo.getTabs();
  }

  Future<void> toggle(String tabId) async {
    final repo = ref.read(navigationSettingsRepositoryProvider);
    await repo.toggleTab(tabId);
    ref.invalidateSelf();
  }
}
