import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/providers/settings_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const _featureRoutes = {
    'dashboard': '/dashboard',
    'inventory': '/inventory',
    'recipes': '/recipes',
    'automation': '/automation',
    'alerts': '/alerts',
  };

  static const _featureIcons = {
    'dashboard': Icons.dashboard,
    'inventory': Icons.inventory_2,
    'recipes': Icons.menu_book,
    'automation': Icons.schedule,
    'alerts': Icons.notifications,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsAsync = ref.watch(navigationTabsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          // Features not in main nav
          tabsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (tabs) {
              final hiddenTabs =
                  tabs.where((t) => !t.inMainNav).toList();
              if (hiddenTabs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Features',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: colorScheme.primary)),
                  ),
                  ...hiddenTabs.map((tab) => ListTile(
                        leading: Icon(_featureIcons[tab.id] ?? Icons.widgets),
                        title: Text(tab.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final route = _featureRoutes[tab.id];
                          if (route != null) context.push(route);
                        },
                      )),
                  const Divider(),
                ],
              );
            },
          ),

          // Management
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Management',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: colorScheme.primary)),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            subtitle: const Text('Manage inventory categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/categories'),
          ),

          const Divider(),

          // Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: colorScheme.primary)),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('App Settings'),
            subtitle: const Text('Customize tabs and dashboard'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            subtitle: const Text('Coming soon'),
            enabled: false,
          ),

          const Divider(),

          // App info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text('Homebase v1.0.0',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
