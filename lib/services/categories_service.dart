import 'package:logger/logger.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoriesService {
  final CategoryRepository _categoryRepo = CategoryRepository();
  final logger = Logger();

  Future<void> saveCategory(Category category) async {
    final cat = await getCategoryById(category.id);

    if (cat == null) {
      await addCategory(category);
    } else {
      await updateCategory(category);
    }
  }

  Future<void> addCategory(Category category) async {
    await _categoryRepo.insert(category);
    logger.i('added category');
  }

  Future<void> updateCategory(Category category) async {
    await _categoryRepo.update(category);
    logger.i('update category');
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryRepo.delete(categoryId);
    logger.i('Delete Category');
  }

  Future<List<Category>> getAllCategories() async {
    final categories = await _categoryRepo.getAll();
    logger.i('Get All Categories');
    logger.i(categories);
    return categories;
  }

  Future<Category?> getCategoryById(String id) async {
    final data = await _categoryRepo.getById(id);
    if (data != null) {
      return data;
    }
    return null;
  }

  Future<List<Category>> filter(String query) async {
    final categories = await _categoryRepo.searchByName(query);
    logger.i('Search Categories');
    logger.i(categories);
    return categories;
  }
}
