import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../inventory/data/inventory_repository.dart';
import '../data/dashboard_settings_repository.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardSettingsRepository dashboardSettingsRepository(
    DashboardSettingsRepositoryRef ref) {
  return DashboardSettingsRepository(database);
}

@riverpod
class DashboardSections extends _$DashboardSections {
  @override
  Future<List<DashboardSection>> build() async {
    final repo = ref.watch(dashboardSettingsRepositoryProvider);
    return repo.getSections();
  }

  Future<void> toggle(String sectionId) async {
    final repo = ref.read(dashboardSettingsRepositoryProvider);
    await repo.toggleSection(sectionId);
    ref.invalidateSelf();
  }
}

@riverpod
Stream<List<InventoryItemWithCategories>> lowStockItems(
    LowStockItemsRef ref) {
  final repo = InventoryRepository(database);
  return repo.watchLowStockItems();
}

@riverpod
Stream<List<InventoryItemWithCategories>> expiringSoonItems(
    ExpiringSoonItemsRef ref) {
  final repo = InventoryRepository(database);
  return repo.watchExpiringSoon(7);
}

@riverpod
Stream<List<InventoryItemWithCategories>> allInventoryItems(
    AllInventoryItemsRef ref) {
  final repo = InventoryRepository(database);
  return repo.watchAllItems();
}
