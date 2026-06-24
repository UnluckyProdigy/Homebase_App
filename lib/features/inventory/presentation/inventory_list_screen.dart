import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../categories/providers/categories_provider.dart';
import '../providers/inventory_provider.dart';
import 'widgets/inventory_item_tile.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredInventoryProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategories = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: () => context.push('/more/categories'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'scan',
            onPressed: () => context.push('/inventory/scan'),
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.push('/inventory/add'),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and category filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                categoriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (categories) {
                    final sorted = [...categories]
                      ..sort((a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    return _CategoryFilterButton(
                      categories: sorted,
                    );
                  },
                ),
              ],
            ),
          ),

          // Active filter indicator
          if (selectedCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.filter_list,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${selectedCategories.length} ${selectedCategories.length == 1 ? 'category' : 'categories'} selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref
                        .read(selectedCategoryFilterProvider.notifier)
                        .clearAll(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Item list
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (items) {
                final filtered = _searchQuery.isEmpty
                    ? items
                    : items
                        .where((ic) => ic.item.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No items match "$_searchQuery"'
                              : selectedCategories.isNotEmpty
                                  ? 'No items in selected categories'
                                  : 'No items yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isEmpty &&
                            selectedCategories.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Tap + to add your first item'),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ic = filtered[index];
                    return InventoryItemTile(
                      itemWithCategories: ic,
                      onTap: () => context.push(
                        '/inventory/detail/${ic.item.id}',
                      ),
                      onQuantityChanged: (newQty) => ref
                          .read(inventoryRepositoryProvider)
                          .updateQuantity(ic.item.id, newQty),
                      onDelete: () => ref
                          .read(inventoryRepositoryProvider)
                          .deleteItem(ic.item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterButton extends ConsumerWidget {
  final List<Category> categories;

  const _CategoryFilterButton({
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedCategoryFilterProvider);

    return Badge(
      isLabelVisible: selectedIds.isNotEmpty,
      label: Text('${selectedIds.length}'),
      child: IconButton(
        icon: const Icon(Icons.filter_list),
        tooltip: 'Filter by category',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _CategoryFilterDialog(
              categories: categories,
            ),
          );
        },
      ),
    );
  }
}

class _CategoryFilterDialog extends ConsumerWidget {
  final List<Category> categories;

  const _CategoryFilterDialog({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedCategoryFilterProvider);

    return AlertDialog(
      title: const Text('Filter by Category'),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "All Categories" option
            ListTile(
              leading: Icon(
                selectedIds.isEmpty
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selectedIds.isEmpty
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                'All Categories',
                style: TextStyle(
                  fontWeight:
                      selectedIds.isEmpty ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => ref
                  .read(selectedCategoryFilterProvider.notifier)
                  .clearAll(),
            ),
            const Divider(height: 1),
            // Scrollable category list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];
                  final isSelected = selectedIds.contains(c.id);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(c.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (_) => ref
                        .read(selectedCategoryFilterProvider.notifier)
                        .toggle(c.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
