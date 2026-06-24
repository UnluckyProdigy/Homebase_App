import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/alerts/providers/alerts_provider.dart';
import '../../features/automation/presentation/add_rule_screen.dart';
import '../../features/automation/presentation/automation_list_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/add_item_screen.dart';
import '../../features/inventory/presentation/barcode_scanner_screen.dart';
import '../../features/inventory/presentation/inventory_list_screen.dart';
import '../../features/inventory/presentation/item_detail_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/recipes/presentation/add_recipe_screen.dart';
import '../../features/recipes/presentation/meal_suggestions_screen.dart';
import '../../features/recipes/presentation/recipe_detail_screen.dart';
import '../../features/recipes/presentation/recipe_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/providers/settings_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Branch indices must match this order
const _branchIds = ['dashboard', 'inventory', 'recipes', 'automation', 'alerts', 'more'];

const _branchIcons = {
  'dashboard': Icons.dashboard_outlined,
  'dashboard_selected': Icons.dashboard,
  'inventory': Icons.inventory_2_outlined,
  'inventory_selected': Icons.inventory_2,
  'recipes': Icons.menu_book_outlined,
  'recipes_selected': Icons.menu_book,
  'automation': Icons.schedule_outlined,
  'automation_selected': Icons.schedule,
  'alerts': Icons.notifications_outlined,
  'alerts_selected': Icons.notifications,
  'more': Icons.more_horiz,
  'more_selected': Icons.more_horiz,
};

const _branchLabels = {
  'dashboard': 'Dashboard',
  'inventory': 'Inventory',
  'recipes': 'Recipes',
  'automation': 'Automation',
  'alerts': 'Alerts',
  'more': 'More',
};

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // 1: Inventory
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, String?>?;
                    if (extra != null) {
                      return AddItemScreen(
                        prefilledBarcode: extra['barcode'],
                        prefilledName: extra['name'],
                        prefilledBrand: extra['brand'],
                        prefilledImageUrl: extra['imageUrl'],
                      );
                    }
                    return const AddItemScreen();
                  },
                ),
                GoRoute(
                  path: 'scan',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const BarcodeScannerScreen(),
                ),
                GoRoute(
                  path: 'detail/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return ItemDetailScreen(itemId: id);
                  },
                ),
                GoRoute(
                  path: 'edit/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return AddItemScreen(editItemId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // 2: Recipes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) => const RecipeListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const AddRecipeScreen(),
                ),
                GoRoute(
                  path: 'suggestions',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const MealSuggestionsScreen(),
                ),
                GoRoute(
                  path: 'detail/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return RecipeDetailScreen(recipeId: id);
                  },
                ),
                GoRoute(
                  path: 'edit/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return AddRecipeScreen(editRecipeId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // 3: Automation
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/automation',
              builder: (context, state) => const AutomationListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final itemId = state.extra as int?;
                    return AddRuleScreen(preselectedItemId: itemId);
                  },
                ),
                GoRoute(
                  path: 'edit/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return AddRuleScreen(editRuleId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // 4: Alerts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
          ],
        ),
        // 5: More
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'categories',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CategoriesScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsAsync = ref.watch(navigationTabsProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);

    final mainTabIds = tabsAsync.valueOrNull
            ?.where((t) => t.inMainNav)
            .map((t) => t.id)
            .toList() ??
        ['dashboard', 'inventory', 'recipes', 'alerts'];

    // Map visible nav indices to branch indices
    // Main tabs + More tab (always last)
    final visibleBranchIndices = [
      ...mainTabIds.map((id) => _branchIds.indexOf(id)),
      _branchIds.indexOf('more'),
    ];

    // Find which visible index is currently selected
    final currentBranch = navigationShell.currentIndex;
    int selectedVisible = visibleBranchIndices.indexOf(currentBranch);
    if (selectedVisible < 0) {
      selectedVisible = visibleBranchIndices.length - 1; // Default to More
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedVisible,
        onDestinationSelected: (visibleIndex) {
          final branchIndex = visibleBranchIndices[visibleIndex];
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: [
          ...mainTabIds.map((id) {
            final icon = _branchIcons[id] ?? Icons.widgets;
            final selectedIcon =
                _branchIcons['${id}_selected'] ?? Icons.widgets;
            final label = _branchLabels[id] ?? id;

            if (id == 'alerts') {
              final count = unreadCount.valueOrNull ?? 0;
              return NavigationDestination(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(icon),
                ),
                selectedIcon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(selectedIcon),
                ),
                label: label,
              );
            }

            return NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            );
          }),
          const NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
