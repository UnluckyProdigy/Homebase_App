import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get iconName => text().withDefault(const Constant('category'))();
  TextColumn get colorHex =>
      text().withDefault(const Constant('#607D8B'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryIds =>
      text().withDefault(const Constant('[]'))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get unit => text().withDefault(const Constant('item'))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get lowStockAlertEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get lowStockThreshold =>
      integer().withDefault(const Constant(2))();
  TextColumn get priority =>
      text().withDefault(const Constant('normal'))();
  TextColumn get brand => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class AutomationRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(InventoryItems, #id,
      onDelete: KeyAction.cascade)();
  IntColumn get decrementAmount =>
      integer().withDefault(const Constant(1))();
  TextColumn get scheduleType => text()();
  TextColumn get customDays => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get lastRunDate => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class AlertHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(InventoryItems, #id,
      onDelete: KeyAction.cascade)();
  TextColumn get alertType => text()();
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get instructions => text()();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  TextColumn get difficulty =>
      text().withDefault(const Constant('easy'))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer().references(Recipes, #id,
      onDelete: KeyAction.cascade)();
  IntColumn get inventoryItemId => integer().nullable().references(
      InventoryItems, #id,
      onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('item'))();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Categories,
  InventoryItems,
  AutomationRules,
  AlertHistory,
  AppSettings,
  Recipes,
  RecipeIngredients,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'homebase_db');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // During development, destructive migration is fine
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        await _seedCategories();
      },
    );
  }

  Future<void> _seedCategories() async {
    final defaults = [
      ('Fruits', 'restaurant', '#4CAF50', 0),
      ('Vegetables', 'eco', '#8BC34A', 1),
      ('Dairy', 'water_drop', '#FFC107', 2),
      ('Meat & Seafood', 'set_meal', '#F44336', 3),
      ('Pantry', 'kitchen', '#795548', 4),
      ('Frozen', 'ac_unit', '#03A9F4', 5),
      ('Beverages', 'local_cafe', '#9C27B0', 6),
      ('Snacks', 'cookie', '#FF9800', 7),
      ('Cleaning', 'cleaning_services', '#00BCD4', 8),
      ('Toiletries', 'soap', '#E91E63', 9),
      ('Laundry', 'local_laundry_service', '#3F51B5', 10),
      ('Medicine', 'medical_services', '#F44336', 11),
      ('Other', 'category', '#607D8B', 12),
    ];

    for (final (name, icon, color, order) in defaults) {
      await into(categories).insert(CategoriesCompanion.insert(
        name: name,
        iconName: Value(icon),
        colorHex: Value(color),
        isDefault: const Value(true),
        sortOrder: Value(order),
      ));
    }
  }
}
