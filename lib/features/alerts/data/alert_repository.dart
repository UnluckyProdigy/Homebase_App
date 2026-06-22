import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class AlertWithItem {
  final AlertHistoryData alert;
  final InventoryItem item;

  AlertWithItem({required this.alert, required this.item});
}

class AlertRepository {
  final AppDatabase _db;

  AlertRepository(this._db);

  Stream<List<AlertWithItem>> watchAllAlerts() {
    final query = _db.select(_db.alertHistory).join([
      innerJoin(_db.inventoryItems,
          _db.inventoryItems.id.equalsExp(_db.alertHistory.itemId)),
    ])
      ..orderBy([OrderingTerm.desc(_db.alertHistory.createdAt)]);

    return query.watch().map((rows) => rows.map((row) {
          return AlertWithItem(
            alert: row.readTable(_db.alertHistory),
            item: row.readTable(_db.inventoryItems),
          );
        }).toList());
  }

  Stream<int> watchUnreadCount() {
    final query = _db.selectOnly(_db.alertHistory)
      ..addColumns([_db.alertHistory.id.count()])
      ..where(_db.alertHistory.isRead.equals(false));

    return query.watchSingle().map(
        (row) => row.read(_db.alertHistory.id.count()) ?? 0);
  }

  Future<void> insertAlert({
    required int itemId,
    required String alertType,
    required String message,
  }) async {
    await _db.into(_db.alertHistory).insert(
      AlertHistoryCompanion.insert(
        itemId: itemId,
        alertType: alertType,
        message: message,
      ),
    );
  }

  Future<bool> hasRecentAlert({
    required int itemId,
    required String alertType,
    Duration within = const Duration(hours: 12),
  }) async {
    final cutoff = DateTime.now().subtract(within);
    final result = await (_db.select(_db.alertHistory)
          ..where((a) =>
              a.itemId.equals(itemId) &
              a.alertType.equals(alertType) &
              a.createdAt.isBiggerOrEqualValue(cutoff)))
        .get();
    return result.isNotEmpty;
  }

  Future<void> markAsRead(int id) async {
    await (_db.update(_db.alertHistory)..where((a) => a.id.equals(id)))
        .write(const AlertHistoryCompanion(isRead: Value(true)));
  }

  Future<void> markAllAsRead() async {
    await (_db.update(_db.alertHistory)
          ..where((a) => a.isRead.equals(false)))
        .write(const AlertHistoryCompanion(isRead: Value(true)));
  }

  Future<void> deleteAlert(int id) async {
    await (_db.delete(_db.alertHistory)..where((a) => a.id.equals(id))).go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.alertHistory).go();
  }
}
