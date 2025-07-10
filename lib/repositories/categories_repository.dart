import 'package:logger/logger.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoriesRepository {
  final CategoryService _categoryRepo = CategoryService();
  final logger = Logger();

  Future<void> saveCategory(CategoryModel category) async {
    final cat = await getCategoryById(category.id);

    if (cat == null) {
      await addCategory(category);
    } else {
      await updateCategory(category);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryRepo.insert(category);
    logger.i('added category');
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryRepo.update(category);
    logger.i('update category');
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryRepo.delete(categoryId);
    logger.i('Delete Category');
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final categories = await _categoryRepo.getAll();
    logger.i('Get All Categories');
    logger.i(categories);
    return categories;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final data = await _categoryRepo.getById(id);
    if (data != null) {
      return data;
    }
    return null;
  }

  Future<List<CategoryModel>> filter(String query) async {
    final categories = await _categoryRepo.searchByName(query);
    logger.i('Search Categories');
    logger.i(categories);
    return categories;
  }
}
