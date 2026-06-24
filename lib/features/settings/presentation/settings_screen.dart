import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/providers/dashboard_provider.dart';
import '../data/navigation_settings_repository.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _tabIcons = {
    'dashboard': Icons.dashboard,
    'inventory': Icons.inventory_2,
    'recipes': Icons.menu_book,
    'automation': Icons.schedule,
    'alerts': Icons.notifications,
  };

  static const _sectionIcons = {
    'summary': Icons.bar_chart,
    'quick_actions': Icons.bolt,
    'low_stock': Icons.warning_amber,
    'expiring': Icons.schedule,
    'suggested_meals': Icons.restaurant_menu,
    'recent_recipes': Icons.menu_book,
  };

  static const _sectionDescriptions = {
    'summary': 'Total items, low stock, out of stock, and expiring counts',
    'quick_actions': 'Quick access to inventory, scan, and add item',
    'low_stock': 'Items at or below their alert threshold',
    'expiring': 'Items expiring within the next 7 days',
    'suggested_meals': 'Recipes using soon-to-expire ingredients',
    'recent_recipes': 'Recently added or favorite recipes',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsAsync = ref.watch(navigationTabsProvider);
    final sectionsAsync = ref.watch(dashboardSectionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Tab customization
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Main Tabs',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: colorScheme.primary)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Choose up to 4 tabs for the main navigation bar. Others will appear in the More tab.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          tabsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
            data: (tabs) {
              final mainCount = tabs.where((t) => t.inMainNav).length;
              return Column(
                children: tabs.map((tab) {
                  final canToggle = tab.inMainNav
                      ? mainCount > 1
                      : mainCount < NavigationSettingsRepository.maxMainTabs;
                  return SwitchListTile(
                    secondary: Icon(
                      _tabIcons[tab.id] ?? Icons.widgets,
                      color: tab.inMainNav ? colorScheme.primary : null,
                    ),
                    title: Text(tab.label),
                    subtitle: Text(tab.inMainNav
                        ? 'In main navigation'
                        : 'In More tab'),
                    value: tab.inMainNav,
                    onChanged: canToggle
                        ? (_) => ref
                            .read(navigationTabsProvider.notifier)
                            .toggle(tab.id)
                        : null,
                  );
                }).toList(),
              );
            },
          ),

          const Divider(height: 32),

          // Dashboard customization
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text('Dashboard Sections',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: colorScheme.primary)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Choose which sections appear on the dashboard.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          sectionsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
            data: (sections) => Column(
              children: sections.map((section) {
                return SwitchListTile(
                  secondary: Icon(
                    _sectionIcons[section.id] ?? Icons.widgets,
                    color: section.visible ? colorScheme.primary : null,
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
