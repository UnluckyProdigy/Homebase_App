import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/icon_helper.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../providers/inventory_provider.dart';

class ItemDetailScreen extends ConsumerWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(inventoryItemByIdProvider(itemId));
    final colorScheme = Theme.of(context).colorScheme;

    return itemAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (ic) {
        final item = ic.item;
        final categories = ic.categories;

        final isExpired = item.expirationDate != null &&
            item.expirationDate!.isBefore(DateTime.now());
        final isExpiringSoon = item.expirationDate != null &&
            !isExpired &&
            item.expirationDate!.difference(DateTime.now()).inDays <= 3;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/inventory/edit/${item.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Item'),
                      content:
                          Text('Delete "${item.name}" from inventory?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(inventoryRepositoryProvider)
                        .deleteItem(item.id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Category badges
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...categories.map((cat) {
                    final catColor = IconHelper.parseColor(cat.colorHex);
                    return Chip(
                      avatar: Icon(
                        IconHelper.getIcon(cat.iconName),
                        color: catColor,
                        size: 18,
                      ),
                      label: Text(cat.name),
                      backgroundColor: catColor.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    );
                  }),
                  if (item.priority == 'must_have')
                    Chip(
                      avatar: Icon(Icons.star,
                          color: Colors.amber[700], size: 18),
                      label: const Text('Must Have'),
                      backgroundColor:
                          Colors.amber.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Quantity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Quantity',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      QuantityStepper(
                        quantity: item.quantity,
                        onChanged: (v) => ref
                            .read(inventoryRepositoryProvider)
                            .updateQuantity(item.id, v),
                      ),
                      const SizedBox(height: 4),
                      Text('${item.unit}s',
                          style: Theme.of(context).textTheme.bodySmall),
                      if (item.lowStockAlertEnabled &&
                          item.quantity <= item.lowStockThreshold)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.quantity == 0
                                    ? Icons.error
                                    : Icons.warning_amber,
                                size: 16,
                                color: item.quantity == 0
                                    ? colorScheme.error
                                    : Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.quantity == 0
                                    ? 'Out of stock!'
                                    : 'Low stock (threshold: ${item.lowStockThreshold})',
                                style: TextStyle(
                                  color: item.quantity == 0
                                      ? colorScheme.error
                                      : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Details',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (item.brand != null)
                        _detailRow('Brand', item.brand!),
                      if (item.barcode != null)
                        _detailRow('Barcode', item.barcode!),
                      if (item.description != null)
                        _detailRow('Description', item.description!),
                      _detailRow('Added',
                          DateFormat.yMMMd().format(item.createdAt)),
                      if (item.expirationDate != null)
                        _detailRow(
                          'Expires',
                          DateFormat.yMMMd()
                              .format(item.expirationDate!),
                          valueColor: isExpired
                              ? colorScheme.error
                              : isExpiringSoon
                                  ? Colors.orange[700]
                                  : null,
                        ),
                      if (item.notes != null) ...[
                        const SizedBox(height: 8),
                        Text('Notes',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(item.notes!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actions',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                              '/automation/add',
                              extra: item.id),
                          icon: const Icon(Icons.schedule),
                          label: const Text('Add Automation Rule'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: valueColor != null
                    ? TextStyle(
                        color: valueColor, fontWeight: FontWeight.bold)
                    : null),
          ),
        ],
      ),
    );
  }
}
