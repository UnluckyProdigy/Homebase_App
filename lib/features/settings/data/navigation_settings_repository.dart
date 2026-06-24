import 'dart:convert';

import '../../../core/database/app_database.dart';

class NavTab {
  final String id;
  final String label;
  final String iconName;
  final bool inMainNav;

  NavTab({
    required this.id,
    required this.label,
    required this.iconName,
    required this.inMainNav,
  });

  NavTab copyWith({bool? inMainNav}) => NavTab(
        id: id,
        label: label,
        iconName: iconName,
        inMainNav: inMainNav ?? this.inMainNav,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconName': iconName,
        'inMainNav': inMainNav,
      };

  factory NavTab.fromJson(Map<String, dynamic> json) => NavTab(
        id: json['id'] as String,
        label: json['label'] as String,
        iconName: json['iconName'] as String,
        inMainNav: json['inMainNav'] as bool,
      );
}

class NavigationSettingsRepository {
  final AppDatabase _db;

  static const _settingsKey = 'nav_tab_config';
  static const int maxMainTabs = 4;

  static final List<NavTab> defaultTabs = [
    NavTab(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard', inMainNav: true),
    NavTab(id: 'inventory', label: 'Inventory', iconName: 'inventory_2', inMainNav: true),
    NavTab(id: 'recipes', label: 'Recipes', iconName: 'menu_book', inMainNav: true),
    NavTab(id: 'automation', label: 'Automation', iconName: 'schedule', inMainNav: false),
    NavTab(id: 'alerts', label: 'Alerts', iconName: 'notifications', inMainNav: true),
  ];

  NavigationSettingsRepository(this._db);

  Future<List<NavTab>> getTabs() async {
    final setting = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_settingsKey)))
        .getSingleOrNull();

    if (setting == null) return defaultTabs;

    final list = (jsonDecode(setting.value) as List)
        .map((e) => NavTab.fromJson(e as Map<String, dynamic>))
        .toList();

    // Merge with defaults in case new tabs were added
    final savedIds = list.map((t) => t.id).toSet();
    for (final def in defaultTabs) {
      if (!savedIds.contains(def.id)) {
        list.add(def);
      }
    }
    return list;
  }

  Future<void> saveTabs(List<NavTab> tabs) async {
    final json = jsonEncode(tabs.map((t) => t.toJson()).toList());
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _settingsKey, value: json),
        );
  }

  Future<void> toggleTab(String tabId) async {
    final tabs = await getTabs();
    final mainCount = tabs.where((t) => t.inMainNav).length;
    final tab = tabs.firstWhere((t) => t.id == tabId);

    if (tab.inMainNav && mainCount <= 1) return;
    if (!tab.inMainNav && mainCount >= maxMainTabs) return;

    final updated = tabs.map((t) {
      if (t.id == tabId) return t.copyWith(inMainNav: !t.inMainNav);
      return t;
    }).toList();
    await saveTabs(updated);
  }
}
