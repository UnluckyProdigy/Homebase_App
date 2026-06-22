import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../data/alert_repository.dart';

part 'alerts_provider.g.dart';

@riverpod
AlertRepository alertRepository(AlertRepositoryRef ref) {
  return AlertRepository(database);
}

@riverpod
Stream<List<AlertWithItem>> alertsStream(AlertsStreamRef ref) {
  final repo = ref.watch(alertRepositoryProvider);
  return repo.watchAllAlerts();
}

@riverpod
Stream<int> unreadAlertCount(UnreadAlertCountRef ref) {
  final repo = ref.watch(alertRepositoryProvider);
  return repo.watchUnreadCount();
}
