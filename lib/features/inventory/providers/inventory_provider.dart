import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../data/inventory_repository.dart';

part 'inventory_provider.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return InventoryRepository(database);
}

@riverpod
Stream<List<InventoryItemWithCategories>> inventoryStream(
    InventoryStreamRef ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchAllItems();
}

@riverpod
Stream<InventoryItemWithCategories> inventoryItemById(
    InventoryItemByIdRef ref, int id) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchItemById(id);
}

@riverpod
class SelectedCategoryFilter extends _$SelectedCategoryFilter {
  @override
  Set<int> build() => {};

  void toggle(int categoryId) {
    if (state.contains(categoryId)) {
      state = {...state}..remove(categoryId);
    } else {
      state = {...state, categoryId};
    }
  }

  void clearAll() => state = {};
}

@riverpod
Stream<List<InventoryItemWithCategories>> filteredInventory(
    FilteredInventoryRef ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final categoryIds = ref.watch(selectedCategoryFilterProvider);

  if (categoryIds.isNotEmpty) {
    return repo.watchItemsByCategories(categoryIds);
  }
  return repo.watchAllItems();
}
