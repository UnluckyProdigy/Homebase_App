class AppConstants {
  static const String appName = 'Homebase';

  static const String openFoodFactsBaseUrl =
      'https://world.openfoodfacts.net/api/v2/product';
  static const String upcItemDbBaseUrl =
      'https://api.upcitemdb.com/prod/trial/lookup';

  static const int defaultLowStockThreshold = 2;
  static const int defaultExpirationAlertDays = 3;
}

enum ItemPriority {
  normal('Normal'),
  mustHave('Must Have');

  final String label;
  const ItemPriority(this.label);
}

enum ScheduleType {
  daily('Daily'),
  weekdays('Weekdays'),
  weekends('Weekends'),
  custom('Custom');

  final String label;
  const ScheduleType(this.label);
}

enum AlertType {
  lowStock('Low Stock'),
  outOfStock('Out of Stock'),
  expiringSoon('Expiring Soon'),
  expired('Expired');

  final String label;
  const AlertType(this.label);
}
