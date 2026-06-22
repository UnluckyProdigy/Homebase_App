import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/icon_helper.dart';
import '../../data/inventory_repository.dart';

class InventoryItemTile extends StatelessWidget {
  final InventoryItemWithCategories itemWithCategories;
  final VoidCallback onTap;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const InventoryItemTile({
    super.key,
    required this.itemWithCategories,
    required this.onTap,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final item = itemWithCategories.item;
    final categories = itemWithCategories.categories;
    final colorScheme = Theme.of(context).colorScheme;

    final isLowStock = item.lowStockAlertEnabled &&
        item.quantity <= item.lowStockThreshold;
    final isOutOfStock = item.quantity == 0;
    final isExpiringSoon = item.expirationDate != null &&
        item.expirationDate!.difference(DateTime.now()).inDays <= 3 &&
        item.expirationDate!.isAfter(DateTime.now());
    final isExpired = item.expirationDate != null &&
        item.expirationDate!.isBefore(DateTime.now());

    // Use first category for the avatar color
    final primaryCategory = categories.isNotEmpty ? categories.first : null;
    final avatarColor = primaryCategory != null
        ? IconHelper.parseColor(primaryCategory.colorHex)
        : Colors.grey;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Delete "${item.name}" from inventory?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.2),
          child: primaryCategory != null
              ? Icon(
                  IconHelper.getIcon(primaryCategory.iconName),
                  color: avatarColor,
                  size: 20,
                )
              : const Icon(Icons.category, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(item.name)),
            if (item.priority == 'must_have')
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.star, size: 16, color: Colors.amber[700]),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(categories.map((c) => c.name).join(', ')),
            if (isExpired)
              Text(
                  'Expired ${DateFormat.MMMd().format(item.expirationDate!)}',
                  style:
                      TextStyle(color: colorScheme.error, fontSize: 12))
            else if (isExpiringSoon)
              Text(
                  'Expires ${DateFormat.MMMd().format(item.expirationDate!)}',
                  style: TextStyle(
                      color: Colors.orange[700], fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: item.quantity > 0
                  ? () => onQuantityChanged(item.quantity - 1)
                  : null,
              iconSize: 20,
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock
                      ? colorScheme.error
                      : isLowStock
                          ? Colors.orange[700]
                          : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onQuantityChanged(item.quantity + 1),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
