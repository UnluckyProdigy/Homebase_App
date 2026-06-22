import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import 'notification_service.dart';

const _automationTaskName = 'homebase_automation';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _automationTaskName || taskName == Workmanager.iOSBackgroundTask) {
      try {
        final db = AppDatabase();
        await _runAutomationCheck(db);
        await _runExpirationCheck(db);
        await _runLowStockCheck(db);
        await db.close();
      } catch (e) {
        debugPrint('Background task error: $e');
      }
    }
    return true;
  });
}

class BackgroundTaskService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      _automationTaskName,
      _automationTaskName,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> runForegroundCatchUp(AppDatabase db) async {
    try {
      await _runAutomationCheck(db);
      await _runExpirationCheck(db);
      await _runLowStockCheck(db);
    } catch (e) {
      debugPrint('Foreground catch-up error: $e');
    }
  }
}

Future<void> _runAutomationCheck(AppDatabase db) async {
  final today = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(today);

  final rules = await (db.select(db.automationRules)
        ..where((r) => r.isActive.equals(true)))
      .get();

  for (final rule in rules) {
    // Check if already ran today
    if (rule.lastRunDate == todayStr) continue;

    if (!_shouldRunToday(rule, today)) continue;

    // Get the item
    final item = await (db.select(db.inventoryItems)
          ..where((i) => i.id.equals(rule.itemId)))
        .getSingleOrNull();
    if (item == null || item.quantity == 0) continue;

    // Calculate missed days for catch-up
    int missedRuns = 1;
    if (rule.lastRunDate != null) {
      final lastRun = DateFormat('yyyy-MM-dd').parse(rule.lastRunDate!);
      final daysSince = today.difference(lastRun).inDays;
      if (daysSince > 1) {
        missedRuns = _countMissedRuns(rule, lastRun, today);
      }
    }

    final totalDecrement = rule.decrementAmount * missedRuns;
    final newQuantity = (item.quantity - totalDecrement).clamp(0, item.quantity);

    // Update quantity
    await (db.update(db.inventoryItems)..where((i) => i.id.equals(item.id)))
        .write(InventoryItemsCompanion(
      quantity: Value(newQuantity),
      updatedAt: Value(DateTime.now()),
    ));

    // Update last run date
    await (db.update(db.automationRules)..where((r) => r.id.equals(rule.id)))
        .write(AutomationRulesCompanion(lastRunDate: Value(todayStr)));

    // Check if low stock alert needed
    if (item.lowStockAlertEnabled && newQuantity <= item.lowStockThreshold) {
      final alertType = newQuantity == 0 ? 'out_of_stock' : 'low_stock';
      final hasRecent = await _hasRecentAlert(db, item.id, alertType);
      if (!hasRecent) {
        await db.into(db.alertHistory).insert(AlertHistoryCompanion.insert(
              itemId: item.id,
              alertType: alertType,
              message: newQuantity == 0
                  ? '${item.name} is out of stock (auto-decremented)'
                  : '${item.name} is low: $newQuantity left (threshold: ${item.lowStockThreshold})',
            ));

        try {
          await NotificationService.showLowStockNotification(
            id: item.id,
            itemName: item.name,
            quantity: newQuantity,
            threshold: item.lowStockThreshold,
            isMustHave: item.priority == 'must_have',
          );
        } catch (_) {}
      }
    }
  }
}

Future<void> _runExpirationCheck(AppDatabase db) async {
  final now = DateTime.now();
  final alertWindow = now.add(const Duration(days: 7));

  final items = await (db.select(db.inventoryItems)
        ..where((i) =>
            i.expirationDate.isNotNull() & i.quantity.isBiggerThanValue(0)))
      .get();

  for (final item in items) {
    if (item.expirationDate == null) continue;

    final isExpired = item.expirationDate!.isBefore(now);
    final isExpiringSoon =
        !isExpired && item.expirationDate!.isBefore(alertWindow);

    if (!isExpired && !isExpiringSoon) continue;

    final alertType = isExpired ? 'expired' : 'expiring_soon';
    final hasRecent = await _hasRecentAlert(db, item.id, alertType);
    if (hasRecent) continue;

    final daysLeft = item.expirationDate!.difference(now).inDays;

    await db.into(db.alertHistory).insert(AlertHistoryCompanion.insert(
          itemId: item.id,
          alertType: alertType,
          message: isExpired
              ? '${item.name} has expired'
              : '${item.name} expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',
        ));

    try {
      await NotificationService.showExpirationNotification(
        id: item.id,
        itemName: item.name,
        isExpired: isExpired,
        daysLeft: daysLeft,
        isMustHave: item.priority == 'must_have',
      );
    } catch (_) {}
  }
}

Future<void> _runLowStockCheck(AppDatabase db) async {
  final items = await db.select(db.inventoryItems).get();

  for (final item in items) {
    if (!item.lowStockAlertEnabled) continue;
    if (item.quantity > item.lowStockThreshold) continue;

    final alertType = item.quantity == 0 ? 'out_of_stock' : 'low_stock';
    final hasRecent = await _hasRecentAlert(db, item.id, alertType);
    if (hasRecent) continue;

    await db.into(db.alertHistory).insert(AlertHistoryCompanion.insert(
          itemId: item.id,
          alertType: alertType,
          message: item.quantity == 0
              ? '${item.name} is out of stock'
              : '${item.name} is running low: ${item.quantity} left (threshold: ${item.lowStockThreshold})',
        ));

    try {
      await NotificationService.showLowStockNotification(
        id: item.id,
        itemName: item.name,
        quantity: item.quantity,
        threshold: item.lowStockThreshold,
        isMustHave: item.priority == 'must_have',
      );
    } catch (_) {}
  }
}

bool _shouldRunToday(AutomationRule rule, DateTime date) {
  final weekday = date.weekday; // 1=Monday, 7=Sunday
  switch (rule.scheduleType) {
    case 'daily':
      return true;
    case 'weekdays':
      return weekday >= 1 && weekday <= 5;
    case 'weekends':
      return weekday == 6 || weekday == 7;
    case 'custom':
      if (rule.customDays == null) return false;
      final days = (jsonDecode(rule.customDays!) as List).cast<String>();
      const dayNames = [
        'monday', 'tuesday', 'wednesday', 'thursday',
        'friday', 'saturday', 'sunday'
      ];
      return days.contains(dayNames[weekday - 1]);
    default:
      return false;
  }
}

int _countMissedRuns(AutomationRule rule, DateTime from, DateTime to) {
  int count = 0;
  var current = from.add(const Duration(days: 1));
  while (!current.isAfter(to)) {
    if (_shouldRunToday(rule, current)) count++;
    current = current.add(const Duration(days: 1));
  }
  return count.clamp(1, 30);
}

Future<bool> _hasRecentAlert(
    AppDatabase db, int itemId, String alertType) async {
  final cutoff = DateTime.now().subtract(const Duration(hours: 12));
  final result = await (db.select(db.alertHistory)
        ..where((a) =>
            a.itemId.equals(itemId) &
            a.alertType.equals(alertType) &
            a.createdAt.isBiggerOrEqualValue(cutoff)))
      .get();
  return result.isNotEmpty;
}
