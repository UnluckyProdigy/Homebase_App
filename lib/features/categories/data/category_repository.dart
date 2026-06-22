import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Stream<List<Category>> watchAllCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<List<Category>> getAllCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<Category> getCategoryById(int id) {
    return (_db.select(_db.categories)..where((c) => c.id.equals(id)))
        .getSingle();
  }

  Future<int> insertCategory({
    required String name,
    required String iconName,
    required String colorHex,
  }) {
    final maxSortOrder = _db.categories.sortOrder.max();
    return _db.transaction(() async {
      final result = await (_db.selectOnly(_db.categories)
            ..addColumns([maxSortOrder]))
          .getSingle();
      final nextOrder = (result.read(maxSortOrder) ?? -1) + 1;

      return _db.into(_db.categories).insert(CategoriesCompanion.insert(
            name: name,
            iconName: Value(iconName),
            colorHex: Value(colorHex),
            sortOrder: Value(nextOrder),
          ));
    });
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String iconName,
    required String colorHex,
  }) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        iconName: Value(iconName),
        colorHex: Value(colorHex),
      ),
    );
  }

  Future<int> deleteCategory(int id) {
    return (_db.delete(_db.categories)
          ..where((c) => c.id.equals(id) & c.isDefault.equals(false)))
        .go();
  }
}
