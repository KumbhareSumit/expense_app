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

  Future<CategoryModel?> addCategory(CategoryModel category) async {
    try {
      final normalizedCategory = CategoryModel(
        name: category.name,
        iconCode: category.iconCode,
        colorValue: category.colorValue,
        type: category.type.trim().toLowerCase(),
        isCustom: category.isCustom,
      );
      final id = await _dbHelper.insertCategory(normalizedCategory);
      final newCategory = CategoryModel(
        id: id,
        name: normalizedCategory.name,
        iconCode: normalizedCategory.iconCode,
        colorValue: normalizedCategory.colorValue,
        type: normalizedCategory.type,
        isCustom: normalizedCategory.isCustom,
      );
      state = [...state, newCategory];
      return newCategory;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final normalizedCategory = CategoryModel(
        id: category.id,
        name: category.name,
        iconCode: category.iconCode,
        colorValue: category.colorValue,
        type: category.type.trim().toLowerCase(),
        isCustom: category.isCustom,
      );
      await _dbHelper.updateCategory(normalizedCategory);
      state = [
        for (final c in state)
          if (c.id == normalizedCategory.id) normalizedCategory else c
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
