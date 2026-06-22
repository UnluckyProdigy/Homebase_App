import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class AutomationRuleWithItem {
  final AutomationRule rule;
  final InventoryItem item;

  AutomationRuleWithItem({required this.rule, required this.item});

  List<String> get customDaysList =>
      rule.customDays != null
          ? (jsonDecode(rule.customDays!) as List).cast<String>()
          : [];

  String get scheduleDescription {
    switch (rule.scheduleType) {
      case 'daily':
        return 'Every day';
      case 'weekdays':
        return 'Weekdays (Mon–Fri)';
      case 'weekends':
        return 'Weekends (Sat–Sun)';
      case 'custom':
        final days = customDaysList;
        if (days.isEmpty) return 'No days selected';
        final abbreviated = days.map((d) =>
            d[0].toUpperCase() + d.substring(1, 3)).toList();
        return abbreviated.join(', ');
      default:
        return rule.scheduleType;
    }
  }
}

class AutomationRepository {
  final AppDatabase _db;

  AutomationRepository(this._db);

  Stream<List<AutomationRuleWithItem>> watchAllRules() {
    final query = _db.select(_db.automationRules).join([
      innerJoin(_db.inventoryItems,
          _db.inventoryItems.id.equalsExp(_db.automationRules.itemId)),
    ])
      ..orderBy([OrderingTerm.asc(_db.inventoryItems.name)]);

    return query.watch().map((rows) => rows.map((row) {
          return AutomationRuleWithItem(
            rule: row.readTable(_db.automationRules),
            item: row.readTable(_db.inventoryItems),
          );
        }).toList());
  }

  Stream<List<AutomationRuleWithItem>> watchRulesForItem(int itemId) {
    final query = _db.select(_db.automationRules).join([
      innerJoin(_db.inventoryItems,
          _db.inventoryItems.id.equalsExp(_db.automationRules.itemId)),
    ])
      ..where(_db.automationRules.itemId.equals(itemId));

    return query.watch().map((rows) => rows.map((row) {
          return AutomationRuleWithItem(
            rule: row.readTable(_db.automationRules),
            item: row.readTable(_db.inventoryItems),
          );
        }).toList());
  }

  Future<AutomationRuleWithItem> getRuleById(int id) async {
    final query = _db.select(_db.automationRules).join([
      innerJoin(_db.inventoryItems,
          _db.inventoryItems.id.equalsExp(_db.automationRules.itemId)),
    ])
      ..where(_db.automationRules.id.equals(id));

    final row = await query.getSingle();
    return AutomationRuleWithItem(
      rule: row.readTable(_db.automationRules),
      item: row.readTable(_db.inventoryItems),
    );
  }

  Future<int> insertRule({
    required int itemId,
    int decrementAmount = 1,
    required String scheduleType,
    List<String>? customDays,
  }) {
    return _db.into(_db.automationRules).insert(
      AutomationRulesCompanion.insert(
        itemId: itemId,
        decrementAmount: Value(decrementAmount),
        scheduleType: scheduleType,
        customDays: Value(customDays != null ? jsonEncode(customDays) : null),
      ),
    );
  }

  Future<void> updateRule({
    required int id,
    required int itemId,
    int decrementAmount = 1,
    required String scheduleType,
    List<String>? customDays,
  }) async {
    await (_db.update(_db.automationRules)..where((r) => r.id.equals(id)))
        .write(AutomationRulesCompanion(
      itemId: Value(itemId),
      decrementAmount: Value(decrementAmount),
      scheduleType: Value(scheduleType),
      customDays: Value(customDays != null ? jsonEncode(customDays) : null),
    ));
  }

  Future<void> toggleRule(int id, bool isActive) async {
    await (_db.update(_db.automationRules)..where((r) => r.id.equals(id)))
        .write(AutomationRulesCompanion(isActive: Value(isActive)));
  }

  Future<int> deleteRule(int id) {
    return (_db.delete(_db.automationRules)..where((r) => r.id.equals(id)))
        .go();
  }
}
