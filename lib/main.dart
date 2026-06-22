import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/services/background_task_service.dart';
import 'core/services/notification_service.dart';

late AppDatabase database;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  runApp(const ProviderScope(child: HomebaseApp()));

  // Initialize services after UI is showing
  _initServices();
}

Future<void> _initServices() async {
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  try {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await BackgroundTaskService.initialize();
      await BackgroundTaskService.registerPeriodicTask();
    }
  } catch (e) {
    debugPrint('Background task init error: $e');
  }

  try {
    await BackgroundTaskService.runForegroundCatchUp(database);
  } catch (e) {
    debugPrint('Catch-up error: $e');
  }
}
