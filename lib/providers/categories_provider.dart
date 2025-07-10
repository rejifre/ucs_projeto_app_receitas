import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../repositories/categories_repository.dart';

class CategoriesProvider with ChangeNotifier {
  final CategoriesRepository _service = CategoriesRepository();
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  CategoriesProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _categories = await _service.getAllCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await loadCategories(); // Atualiza a lista
  }

  Future<void> addOrUpdateCategory(CategoryModel category) async {
    if (_categories.any((c) => c.id == category.id)) {
      // Se a categoria já existe, atualiza-a
      await _service.updateCategory(category);
    } else {
      // Caso contrário, adiciona uma nova categoria
      await _service.addCategory(category);
    }
    await loadCategories();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    return await _service.getCategoryById(id);
  }

  Future<List<CategoryModel>> searchCategories(String query) async {
    _categories = await _service.filter(query);
    notifyListeners();
    return _categories;
  }
}
