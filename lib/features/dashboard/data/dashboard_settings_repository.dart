import 'dart:convert';

import '../../../core/database/app_database.dart';

class DashboardSection {
  final String id;
  final String label;
  final bool visible;

  DashboardSection({
    required this.id,
    required this.label,
    required this.visible,
  });

  DashboardSection copyWith({bool? visible}) =>
      DashboardSection(id: id, label: label, visible: visible ?? this.visible);

  Map<String, dynamic> toJson() =>
      {'id': id, 'label': label, 'visible': visible};

  factory DashboardSection.fromJson(Map<String, dynamic> json) =>
      DashboardSection(
        id: json['id'] as String,
        label: json['label'] as String,
        visible: json['visible'] as bool,
      );
}

class DashboardSettingsRepository {
  final AppDatabase _db;

  static const _settingsKey = 'dashboard_sections';

  static final List<DashboardSection> defaultSections = [
    DashboardSection(id: 'summary', label: 'Summary Stats', visible: true),
    DashboardSection(id: 'quick_actions', label: 'Quick Actions', visible: true),
    DashboardSection(id: 'low_stock', label: 'Low Stock Items', visible: true),
    DashboardSection(id: 'expiring', label: 'Expiring Soon', visible: true),
    DashboardSection(id: 'suggested_meals', label: 'Suggested Meals', visible: true),
    DashboardSection(id: 'recent_recipes', label: 'Recipes', visible: true),
  ];

  DashboardSettingsRepository(this._db);

  Future<List<DashboardSection>> getSections() async {
    final setting = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_settingsKey)))
        .getSingleOrNull();

    if (setting == null) return defaultSections;

    final list = (jsonDecode(setting.value) as List)
        .map((e) => DashboardSection.fromJson(e as Map<String, dynamic>))
        .toList();

    // Merge with defaults in case new sections were added
    final savedIds = list.map((s) => s.id).toSet();
    for (final def in defaultSections) {
      if (!savedIds.contains(def.id)) {
        list.add(def);
      }
    }
    return list;
  }

  Future<void> saveSections(List<DashboardSection> sections) async {
    final json = jsonEncode(sections.map((s) => s.toJson()).toList());
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _settingsKey, value: json),
        );
  }

  Future<void> toggleSection(String sectionId) async {
    final sections = await getSections();
    final updated = sections.map((s) {
      if (s.id == sectionId) return s.copyWith(visible: !s.visible);
      return s;
    }).toList();
    await saveSections(updated);
  }
}
