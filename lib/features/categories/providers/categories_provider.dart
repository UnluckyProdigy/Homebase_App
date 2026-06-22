import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../data/category_repository.dart';

part 'categories_provider.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(database);
}

@riverpod
Stream<List<Category>> categoriesStream(CategoriesStreamRef ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
}
