import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_provider.dart';

class CustomizeDashboardScreen extends ConsumerWidget {
  const CustomizeDashboardScreen({super.key});

  static const _sectionIcons = {
    'summary': Icons.bar_chart,
    'quick_actions': Icons.bolt,
    'low_stock': Icons.warning_amber,
    'expiring': Icons.schedule,
  };

  static const _sectionDescriptions = {
    'summary': 'Total items, low stock, out of stock, and expiring counts',
    'quick_actions': 'Quick access to inventory, scan, and add item',
    'low_stock': 'Items at or below their alert threshold',
    'expiring': 'Items expiring within the next 7 days',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(dashboardSectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customize Dashboard')),
      body: sectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sections) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return SwitchListTile(
              secondary: Icon(
                _sectionIcons[section.id] ?? Icons.widgets,
                color: section.visible
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(section.label),
              subtitle: Text(
                _sectionDescriptions[section.id] ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: section.visible,
              onChanged: (_) => ref
                  .read(dashboardSectionsProvider.notifier)
                  .toggle(section.id),
            );
          },
        ),
      ),
    );
  }
}
