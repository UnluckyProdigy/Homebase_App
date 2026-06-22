import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/alert_repository.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          alertsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (alerts) {
              final hasUnread = alerts.any((a) => !a.alert.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    ref.read(alertRepositoryProvider).markAllAsRead(),
                child: const Text('Mark all read'),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _confirmClear(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear all alerts'),
              ),
            ],
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No alerts',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Alerts for low stock and expiring items\nwill appear here',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alertWithItem = alerts[index];
              return _AlertTile(alertWithItem: alertWithItem);
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Alerts'),
        content: const Text('This will remove all alert history. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(alertRepositoryProvider).clearAll();
    }
  }
}

class _AlertTile extends ConsumerWidget {
  final AlertWithItem alertWithItem;

  const _AlertTile({required this.alertWithItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = alertWithItem.alert;
    final item = alertWithItem.item;
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, color) = switch (alert.alertType) {
      'out_of_stock' => (Icons.error, colorScheme.error),
      'low_stock' => (Icons.warning_amber, Colors.orange[700]!),
      'expired' => (Icons.event_busy, colorScheme.error),
      'expiring_soon' => (Icons.schedule, Colors.orange[700]!),
      _ => (Icons.notifications, colorScheme.primary),
    };

    final typeLabel = switch (alert.alertType) {
      'out_of_stock' => 'Out of Stock',
      'low_stock' => 'Low Stock',
      'expired' => 'Expired',
      'expiring_soon' => 'Expiring Soon',
      _ => alert.alertType,
    };

    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (_) =>
          ref.read(alertRepositoryProvider).deleteAlert(alert.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(typeLabel,
                      style: TextStyle(fontSize: 10, color: color)),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat.MMMd().add_jm().format(alert.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: alert.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!alert.isRead) {
            ref.read(alertRepositoryProvider).markAsRead(alert.id);
          }
          context.push('/inventory/detail/${item.id}');
        },
      ),
    );
  }
}
