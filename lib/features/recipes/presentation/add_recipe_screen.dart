import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/quantity_stepper.dart';
import '../data/recipe_repository.dart';
import '../providers/recipe_provider.dart';
import 'widgets/ingredient_list_editor.dart';
import 'widgets/tag_input_field.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  final int? editRecipeId;

  const AddRecipeScreen({super.key, this.editRecipeId});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructionsController;

  int _servings = 1;
  int? _prepTimeMinutes;
  int? _cookTimeMinutes;
  String _difficulty = 'easy';
  List<IngredientInput> _ingredients = [];
  List<String> _tags = [];
  bool _initialized = false;

  bool get _isEditing => widget.editRecipeId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _instructionsController = TextEditingController();
  }

  void _initFromRecipe(RecipeWithIngredients rw) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = rw.recipe.name;
    _descriptionController.text = rw.recipe.description ?? '';
    _instructionsController.text = rw.recipe.instructions;
    _servings = rw.recipe.servings;
    _prepTimeMinutes = rw.recipe.prepTimeMinutes;
    _cookTimeMinutes = rw.recipe.cookTimeMinutes;
    _difficulty = rw.recipe.difficulty;
    _tags = rw.tagsList;
    _ingredients = rw.ingredients
        .map((ing) => IngredientInput(
              inventoryItemId: ing.inventoryItemId,
              name: ing.name,
              quantity: ing.quantity,
              unit: ing.unit,
            ))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isPrep) async {
    final current = isPrep ? _prepTimeMinutes : _cookTimeMinutes;
    int hours = (current ?? 0) ~/ 60;
    int minutes = (current ?? 0) % 60;

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isPrep ? 'Prep Time' : 'Cook Time'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hours'),
                  QuantityStepper(
                    quantity: hours,
                    onChanged: (v) => setDialogState(() => hours = v),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Minutes'),
                  QuantityStepper(
                    quantity: minutes,
                    onChanged: (v) =>
                        setDialogState(() => minutes = v.clamp(0, 59)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(hours * 60 + minutes),
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );

    setState(() {
      if (isPrep) {
        _prepTimeMinutes = result;
      } else {
        _cookTimeMinutes = result;
      }
    });
  }

  String _formatTime(int? minutes) {
    if (minutes == null) return 'Not set';
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validIngredients =
        _ingredients.where((i) => i.name.trim().isNotEmpty).toList();

    final repo = ref.read(recipeRepositoryProvider);

    if (_isEditing) {
      await repo.updateRecipe(
        id: widget.editRecipeId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        servings: _servings,
        prepTimeMinutes: _prepTimeMinutes,
        cookTimeMinutes: _cookTimeMinutes,
        difficulty: _difficulty,
        tags: _tags,
        ingredients: validIngredients,
      );
    } else {
      await repo.insertRecipe(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        servings: _servings,
        prepTimeMinutes: _prepTimeMinutes,
        cookTimeMinutes: _cookTimeMinutes,
        difficulty: _difficulty,
        tags: _tags,
        ingredients: validIngredients,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !_initialized) {
      final recipeAsync =
          ref.watch(recipeByIdProvider(widget.editRecipeId!));
      recipeAsync.whenData((rw) => _initFromRecipe(rw));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the dish'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Servings
            Row(
              children: [
                Text('Servings',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                QuantityStepper(
                  quantity: _servings,
                  onChanged: (v) => setState(() => _servings = v),
                  min: 1,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Times
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prep Time'),
                    subtitle: Text(_formatTime(_prepTimeMinutes)),
                    trailing: const Icon(Icons.schedule),
                    onTap: () => _pickTime(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Cook Time'),
                    subtitle: Text(_formatTime(_cookTimeMinutes)),
                    trailing: const Icon(Icons.schedule),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Difficulty
            Text('Difficulty',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'easy', label: Text('Easy')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'hard', label: Text('Hard')),
              ],
              selected: {_difficulty},
              onSelectionChanged: (v) =>
                  setState(() => _difficulty = v.first),
            ),
            const SizedBox(height: 24),

            // Ingredients
            IngredientListEditor(
              ingredients: _ingredients,
              onChanged: (v) => setState(() => _ingredients = v),
            ),
            const SizedBox(height: 24),

            // Instructions
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions *',
                hintText: 'Step-by-step cooking instructions...',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Instructions are required'
                  : null,
            ),
            const SizedBox(height: 24),

            // Tags
            TagInputField(
              tags: _tags,
              onChanged: (v) => setState(() => _tags = v),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _save,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label:
                  Text(_isEditing ? 'Save Changes' : 'Create Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
