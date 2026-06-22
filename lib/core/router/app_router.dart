import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/alerts/providers/alerts_provider.dart';
import '../../features/automation/presentation/add_rule_screen.dart';
import '../../features/automation/presentation/automation_list_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/dashboard/presentation/customize_dashboard_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/add_item_screen.dart';
import '../../features/inventory/presentation/barcode_scanner_screen.dart';
import '../../features/inventory/presentation/inventory_list_screen.dart';
import '../../features/inventory/presentation/item_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'customize',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const CustomizeDashboardScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryListScreen(),
              routes: [
                GoRoute(
                  path: 'categories',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CategoriesScreen(),
                ),
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          const NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Automation',
          ),
          Consumer(
            builder: (context, ref, _) {
              final count =
                  ref.watch(unreadAlertCountProvider).valueOrNull ?? 0;
              return NavigationDestination(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications),
                ),
                label: 'Alerts',
              );
            },
          ),
        ],
      ),
    );
  }
}
