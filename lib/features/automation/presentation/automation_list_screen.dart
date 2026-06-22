import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/automation_repository.dart';
import '../providers/automation_provider.dart';

class AutomationListScreen extends ConsumerWidget {
  const AutomationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(automationRulesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/automation/add'),
        child: const Icon(Icons.add),
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No automation rules',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                      'Create rules to auto-decrement items on a schedule'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final ruleWithItem = rules[index];
              return _RuleTile(ruleWithItem: ruleWithItem);
            },
          );
        },
      ),
    );
  }
}

class _RuleTile extends ConsumerWidget {
  final AutomationRuleWithItem ruleWithItem;

  const _RuleTile({required this.ruleWithItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ruleWithItem.rule;
    final item = ruleWithItem.item;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Rule'),
            content: Text(
                'Delete automation rule for "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(automationRepositoryProvider).deleteRule(rule.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rule.isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.autorenew,
            color: rule.isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            color: rule.isActive ? null : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Text(
          'Remove ${rule.decrementAmount} · ${ruleWithItem.scheduleDescription}',
          style: TextStyle(
            color: rule.isActive ? null : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Switch(
          value: rule.isActive,
          onChanged: (v) => ref
              .read(automationRepositoryProvider)
              .toggleRule(rule.id, v),
        ),
        onTap: () => context.push('/automation/edit/${rule.id}'),
      ),
    );
  }
}
