import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/db_helper.dart';
import '../models/category_model.dart';

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final DBHelper _dbHelper = DBHelper();

  CategoryNotifier() : super([]) {
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _dbHelper.getAllCategories();
      state = categories;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final id = await _dbHelper.insertCategory(category);
      final newCategory = CategoryModel(
        id: id,
        name: category.name,
        iconCode: category.iconCode,
        colorValue: category.colorValue,
        type: category.type,
        isCustom: category.isCustom,
      );
      state = [...state, newCategory];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _dbHelper.updateCategory(category);
      state = [
        for (final c in state)
          if (c.id == category.id) category else c
      ];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      state = state.where((c) => c.id != id).toList();
    } catch (e) {
      // Handle error
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier();
});
