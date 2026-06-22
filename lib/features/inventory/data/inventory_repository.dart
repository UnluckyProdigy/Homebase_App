import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class InventoryItemWithCategories {
  final InventoryItem item;
  final List<Category> categories;

  InventoryItemWithCategories({required this.item, required this.categories});

  List<int> get categoryIds =>
      (jsonDecode(item.categoryIds) as List).cast<int>();
}

class InventoryRepository {
  final AppDatabase _db;

  InventoryRepository(this._db);

  Future<Map<int, Category>> _getCategoryMap() async {
    final all = await _db.select(_db.categories).get();
    return {for (final c in all) c.id: c};
  }

  List<Category> _resolveCategories(
      String categoryIdsJson, Map<int, Category> categoryMap) {
    final ids = (jsonDecode(categoryIdsJson) as List).cast<int>();
    return ids
        .map((id) => categoryMap[id])
        .whereType<Category>()
        .toList();
  }

  Stream<List<InventoryItemWithCategories>> watchAllItems() {
    final itemsQuery = _db.select(_db.inventoryItems)
      ..orderBy([(i) => OrderingTerm.asc(i.name)]);

    return itemsQuery.watch().asyncMap((items) async {
      final categoryMap = await _getCategoryMap();
      return items
          .map((item) => InventoryItemWithCategories(
                item: item,
                categories:
                    _resolveCategories(item.categoryIds, categoryMap),
              ))
          .toList();
    });
  }

  Stream<List<InventoryItemWithCategories>> watchItemsByCategories(
      Set<int> filterCategoryIds) {
    return watchAllItems().map((items) => items.where((ic) {
          return ic.categoryIds
              .any((id) => filterCategoryIds.contains(id));
        }).toList());
  }

  Stream<InventoryItemWithCategories> watchItemById(int id) {
    final query = _db.select(_db.inventoryItems)
      ..where((i) => i.id.equals(id));

    return query.watchSingle().asyncMap((item) async {
      final categoryMap = await _getCategoryMap();
      return InventoryItemWithCategories(
        item: item,
        categories: _resolveCategories(item.categoryIds, categoryMap),
      );
    });
  }

  Future<InventoryItemWithCategories> getItemById(int id) async {
    final item = await (_db.select(_db.inventoryItems)
          ..where((i) => i.id.equals(id)))
        .getSingle();
    final categoryMap = await _getCategoryMap();
    return InventoryItemWithCategories(
      item: item,
      categories: _resolveCategories(item.categoryIds, categoryMap),
    );
  }

  Future<InventoryItem?> findByBarcode(String barcode) {
    return (_db.select(_db.inventoryItems)
          ..where((i) => i.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<int> insertItem({
    String? barcode,
    required String name,
    String? description,
    required List<int> categoryIds,
    int quantity = 1,
    String unit = 'item',
    String? imageUrl,
    bool lowStockAlertEnabled = true,
    int lowStockThreshold = 2,
    String priority = 'normal',
    String? brand,
    String? notes,
    DateTime? expirationDate,
  }) {
    return _db.into(_db.inventoryItems).insert(InventoryItemsCompanion.insert(
          barcode: Value(barcode),
          name: name,
          description: Value(description),
          categoryIds: Value(jsonEncode(categoryIds)),
          quantity: Value(quantity),
          unit: Value(unit),
          imageUrl: Value(imageUrl),
          lowStockAlertEnabled: Value(lowStockAlertEnabled),
          lowStockThreshold: Value(lowStockThreshold),
          priority: Value(priority),
          brand: Value(brand),
          notes: Value(notes),
          expirationDate: Value(expirationDate),
        ));
  }

  Future<void> updateItem({
    required int id,
    String? barcode,
    required String name,
    String? description,
    required List<int> categoryIds,
    int quantity = 1,
    String unit = 'item',
    String? imageUrl,
    bool lowStockAlertEnabled = true,
    int lowStockThreshold = 2,
    String priority = 'normal',
    String? brand,
    String? notes,
    DateTime? expirationDate,
  }) async {
    await (_db.update(_db.inventoryItems)..where((i) => i.id.equals(id))).write(
      InventoryItemsCompanion(
        barcode: Value(barcode),
        name: Value(name),
        description: Value(description),
        categoryIds: Value(jsonEncode(categoryIds)),
        quantity: Value(quantity),
        unit: Value(unit),
        imageUrl: Value(imageUrl),
        lowStockAlertEnabled: Value(lowStockAlertEnabled),
        lowStockThreshold: Value(lowStockThreshold),
        priority: Value(priority),
        brand: Value(brand),
        notes: Value(notes),
        expirationDate: Value(expirationDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateQuantity(int id, int newQuantity) async {
    final clamped = newQuantity < 0 ? 0 : newQuantity;
    await (_db.update(_db.inventoryItems)..where((i) => i.id.equals(id))).write(
      InventoryItemsCompanion(
        quantity: Value(clamped),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteItem(int id) {
    return (_db.delete(_db.inventoryItems)..where((i) => i.id.equals(id))).go();
  }

  Stream<List<InventoryItemWithCategories>> watchLowStockItems() {
    return watchAllItems().map((items) => items
        .where((ic) =>
            ic.item.lowStockAlertEnabled &&
            ic.item.quantity <= ic.item.lowStockThreshold)
        .toList()
      ..sort((a, b) => a.item.quantity.compareTo(b.item.quantity)));
  }

  Stream<List<InventoryItemWithCategories>> watchExpiringSoon(int withinDays) {
    final cutoff = DateTime.now().add(Duration(days: withinDays));
    return watchAllItems().map((items) => items
        .where((ic) =>
            ic.item.expirationDate != null &&
            ic.item.expirationDate!.isBefore(cutoff))
        .toList()
      ..sort((a, b) =>
          a.item.expirationDate!.compareTo(b.item.expirationDate!)));
  }
}
