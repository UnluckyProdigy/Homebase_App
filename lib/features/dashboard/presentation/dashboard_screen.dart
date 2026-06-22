import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/icon_helper.dart';
import '../../inventory/data/inventory_repository.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  bool _isSectionVisible(List<dynamic>? sections, String id) {
    if (sections == null) return true;
    final match = sections.where((s) => s.id == id);
    if (match.isEmpty) return true;
    return match.first.visible;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItemsAsync = ref.watch(allInventoryItemsProvider);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final expiringAsync = ref.watch(expiringSoonItemsProvider);
    final sectionsAsync = ref.watch(dashboardSectionsProvider);
    final sections = sectionsAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homebase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Customize Dashboard',
            onPressed: () => context.push('/dashboard/customize'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allInventoryItemsProvider);
          ref.invalidate(lowStockItemsProvider);
          ref.invalidate(expiringSoonItemsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            if (_isSectionVisible(sections, 'summary'))
              allItemsAsync.when(
                loading: () => const _SummaryCard(
                    totalItems: 0,
                    lowStock: 0,
                    outOfStock: 0,
                    expiring: 0),
                error: (e, _) => Card(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $e'),
                )),
                data: (items) {
                  final lowStock = items
                      .where((ic) =>
                          ic.item.lowStockAlertEnabled &&
                          ic.item.quantity <= ic.item.lowStockThreshold &&
                          ic.item.quantity > 0)
                      .length;
                  final outOfStock =
                      items.where((ic) => ic.item.quantity == 0).length;
                  final expiring = items
                      .where((ic) =>
                          ic.item.expirationDate != null &&
                          ic.item.expirationDate!.isBefore(
                              DateTime.now().add(const Duration(days: 7))))
                      .length;

                  return _SummaryCard(
                    totalItems: items.length,
                    lowStock: lowStock,
                    outOfStock: outOfStock,
                    expiring: expiring,
                  );
                },
              ),

            // Quick actions
            if (_isSectionVisible(sections, 'quick_actions')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.go('/inventory'),
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Inventory'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push('/inventory/scan'),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push('/inventory/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ],

            // Low stock preview
            if (_isSectionVisible(sections, 'low_stock')) ...[
              const SizedBox(height: 24),
              lowStockAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => _PreviewWindow(
                  icon: Icons.warning_amber,
                  iconColor: Colors.orange[700]!,
                  title: 'Low Stock',
                  itemCount: items.length,
                  emptyMessage: 'All items are well stocked',
                  items: items,
                  itemBuilder: (ic) =>
                      _DashboardItemTile(ic: ic, type: 'lowStock'),
                  onSeeAll: () => context.go('/inventory'),
                ),
              ),
            ],

            // Expiring soon preview
            if (_isSectionVisible(sections, 'expiring')) ...[
              const SizedBox(height: 16),
              expiringAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => _PreviewWindow(
                  icon: Icons.schedule,
                  iconColor: Colors.red[700]!,
                  title: 'Expiring Soon',
                  itemCount: items.length,
                  emptyMessage: 'No items expiring soon',
                  items: items,
                  itemBuilder: (ic) =>
                      _DashboardItemTile(ic: ic, type: 'expiring'),
                  onSeeAll: () => context.go('/inventory'),
                ),
              ),
            ],

            // Empty state (only when everything is empty and no sections hidden)
            allItemsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) {
                if (items.isNotEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.home,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('Welcome to Homebase!',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text(
                            'Start by scanning a barcode or adding an item manually'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewWindow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int itemCount;
  final String emptyMessage;
  final List<InventoryItemWithCategories> items;
  final Widget Function(InventoryItemWithCategories) itemBuilder;
  final VoidCallback onSeeAll;

  const _PreviewWindow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.itemCount,
    required this.emptyMessage,
    required this.items,
    required this.itemBuilder,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (itemCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$itemCount',
                        style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Content
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(emptyMessage,
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
            )
          else ...[
            ...items.take(4).map(itemBuilder),
            if (items.length > 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSeeAll,
                    child: Text('See all $itemCount items'),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalItems;
  final int lowStock;
  final int outOfStock;
  final int expiring;

  const _SummaryCard({
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
    required this.expiring,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              label: 'Total Items',
              value: '$totalItems',
              color: colorScheme.primary,
              icon: Icons.inventory_2,
            ),
            _StatColumn(
              label: 'Low Stock',
              value: '$lowStock',
              color: Colors.orange[700]!,
              icon: Icons.warning_amber,
            ),
            _StatColumn(
              label: 'Out of Stock',
              value: '$outOfStock',
              color: colorScheme.error,
              icon: Icons.error_outline,
            ),
            _StatColumn(
              label: 'Expiring',
              value: '$expiring',
              color: Colors.red[700]!,
              icon: Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DashboardItemTile extends StatelessWidget {
  final InventoryItemWithCategories ic;
  final String type;

  const _DashboardItemTile({required this.ic, required this.type});

  @override
  Widget build(BuildContext context) {
    final item = ic.item;
    final categories = ic.categories;
    final colorScheme = Theme.of(context).colorScheme;

    final primaryCategory = categories.isNotEmpty ? categories.first : null;
    final avatarColor = primaryCategory != null
        ? IconHelper.parseColor(primaryCategory.colorHex)
        : Colors.grey;

    final isExpired = item.expirationDate != null &&
        item.expirationDate!.isBefore(DateTime.now());

    String subtitle;
    Color subtitleColor;
    if (type == 'expiring') {
      if (isExpired) {
        subtitle = 'Expired ${DateFormat.MMMd().format(item.expirationDate!)}';
        subtitleColor = colorScheme.error;
      } else {
        final daysLeft =
            item.expirationDate!.difference(DateTime.now()).inDays;
        subtitle = daysLeft == 0
            ? 'Expires today'
            : 'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}';
        subtitleColor = Colors.orange[700]!;
      }
    } else {
      subtitle = item.quantity == 0
          ? 'Out of stock'
          : '${item.quantity} left (threshold: ${item.lowStockThreshold})';
      subtitleColor =
          item.quantity == 0 ? colorScheme.error : Colors.orange[700]!;
    }

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: avatarColor.withValues(alpha: 0.2),
        child: primaryCategory != null
            ? Icon(IconHelper.getIcon(primaryCategory.iconName),
                color: avatarColor, size: 16)
            : const Icon(Icons.category, size: 16),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(item.name, style: const TextStyle(fontSize: 14)),
          ),
          if (item.priority == 'must_have')
            Icon(Icons.star, size: 14, color: Colors.amber[700]),
        ],
      ),
      subtitle: Text(subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 12)),
      onTap: () => context.push('/inventory/detail/${item.id}'),
    );
  }
}
