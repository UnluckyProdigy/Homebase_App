import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/quantity_stepper.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../data/automation_repository.dart';
import '../providers/automation_provider.dart';

class AddRuleScreen extends ConsumerStatefulWidget {
  final int? editRuleId;
  final int? preselectedItemId;

  const AddRuleScreen({
    super.key,
    this.editRuleId,
    this.preselectedItemId,
  });

  @override
  ConsumerState<AddRuleScreen> createState() => _AddRuleScreenState();
}

class _AddRuleScreenState extends ConsumerState<AddRuleScreen> {
  int? _selectedItemId;
  int _decrementAmount = 1;
  String _scheduleType = 'daily';
  final Set<String> _customDays = {};
  bool _initialized = false;

  bool get _isEditing => widget.editRuleId != null;

  static const _dayOptions = [
    ('monday', 'Mon'),
    ('tuesday', 'Tue'),
    ('wednesday', 'Wed'),
    ('thursday', 'Thu'),
    ('friday', 'Fri'),
    ('saturday', 'Sat'),
    ('sunday', 'Sun'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.preselectedItemId;
  }

  void _initFromRule(AutomationRuleWithItem ruleWithItem) {
    if (_initialized) return;
    _initialized = true;
    _selectedItemId = ruleWithItem.rule.itemId;
    _decrementAmount = ruleWithItem.rule.decrementAmount;
    _scheduleType = ruleWithItem.rule.scheduleType;
    _customDays.addAll(ruleWithItem.customDaysList);
  }

  Future<void> _save() async {
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
      );
      return;
    }
    if (_scheduleType == 'custom' && _customDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    final repo = ref.read(automationRepositoryProvider);

    if (_isEditing) {
      await repo.updateRule(
        id: widget.editRuleId!,
        itemId: _selectedItemId!,
        decrementAmount: _decrementAmount,
        scheduleType: _scheduleType,
        customDays: _scheduleType == 'custom' ? _customDays.toList() : null,
      );
    } else {
      await repo.insertRule(
        itemId: _selectedItemId!,
        decrementAmount: _decrementAmount,
        scheduleType: _scheduleType,
        customDays: _scheduleType == 'custom' ? _customDays.toList() : null,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (_isEditing && !_initialized) {
      final repo = ref.read(automationRepositoryProvider);
      repo.getRuleById(widget.editRuleId!).then((rule) {
        if (mounted) setState(() => _initFromRule(rule));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Rule' : 'New Automation Rule'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Item picker
          Text('Item', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          itemsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (items) {
              if (items.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No items in inventory. Add items first.',
                        style: TextStyle(color: colorScheme.error)),
                  ),
                );
              }
              return DropdownButtonFormField<int>(
                initialValue: _selectedItemId,
                decoration:
                    const InputDecoration(labelText: 'Select item to automate'),
                items: items
                    .map((ic) => DropdownMenuItem(
                          value: ic.item.id,
                          child: Text(ic.item.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedItemId = v),
              );
            },
          ),
          const SizedBox(height: 24),

          // Decrement amount
          Text('Remove Amount',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              QuantityStepper(
                quantity: _decrementAmount,
                onChanged: (v) => setState(() => _decrementAmount = v),
                min: 1,
              ),
              const SizedBox(width: 12),
              const Text('per scheduled run'),
            ],
          ),
          const SizedBox(height: 24),

          // Schedule type
          Text('Schedule', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'daily', label: Text('Daily')),
              ButtonSegment(value: 'weekdays', label: Text('Weekdays')),
              ButtonSegment(value: 'weekends', label: Text('Weekends')),
              ButtonSegment(value: 'custom', label: Text('Custom')),
            ],
            selected: {_scheduleType},
            onSelectionChanged: (v) =>
                setState(() => _scheduleType = v.first),
          ),
          const SizedBox(height: 16),

          // Custom day picker
          if (_scheduleType == 'custom') ...[
            Text('Select Days',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _dayOptions.map((day) {
                final isSelected = _customDays.contains(day.$1);
                return FilterChip(
                  label: Text(day.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _customDays.add(day.$1);
                      } else {
                        _customDays.remove(day.$1);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Summary
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _buildSummary(),
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _selectedItemId != null ? _save : null,
            icon: Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Save Changes' : 'Create Rule'),
          ),
        ],
      ),
    );
  }

  String _buildSummary() {
    final itemName = _selectedItemId != null ? 'the selected item' : '...';
    final schedule = switch (_scheduleType) {
      'daily' => 'every day',
      'weekdays' => 'on weekdays',
      'weekends' => 'on weekends',
      'custom' => _customDays.isEmpty
          ? 'on selected days'
          : 'on ${_customDays.length} day${_customDays.length == 1 ? '' : 's'}',
      _ => '',
    };
    return 'Remove $_decrementAmount from $itemName $schedule';
  }
}
