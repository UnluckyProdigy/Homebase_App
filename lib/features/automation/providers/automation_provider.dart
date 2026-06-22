import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../data/automation_repository.dart';

part 'automation_provider.g.dart';

@riverpod
AutomationRepository automationRepository(AutomationRepositoryRef ref) {
  return AutomationRepository(database);
}

@riverpod
Stream<List<AutomationRuleWithItem>> automationRulesStream(
    AutomationRulesStreamRef ref) {
  final repo = ref.watch(automationRepositoryProvider);
  return repo.watchAllRules();
}
