import 'package:flutter/material.dart';

class IconHelper {
  static final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'eco': Icons.eco,
    'water_drop': Icons.water_drop,
    'set_meal': Icons.set_meal,
    'kitchen': Icons.kitchen,
    'ac_unit': Icons.ac_unit,
    'local_cafe': Icons.local_cafe,
    'cookie': Icons.cookie,
    'cleaning_services': Icons.cleaning_services,
    'soap': Icons.soap,
    'local_laundry_service': Icons.local_laundry_service,
    'medical_services': Icons.medical_services,
    'category': Icons.category,
    'shopping_cart': Icons.shopping_cart,
    'home': Icons.home,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'build': Icons.build,
    'local_dining': Icons.local_dining,
    'bakery_dining': Icons.bakery_dining,
    'egg': Icons.egg,
    'grass': Icons.grass,
    'spa': Icons.spa,
    'fitness_center': Icons.fitness_center,
  };

  static IconData getIcon(String name) {
    return availableIcons[name] ?? Icons.category;
  }

  static Color parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
