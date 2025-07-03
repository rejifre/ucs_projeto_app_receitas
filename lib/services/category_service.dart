import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';

class CategoryService {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'categories';
  static const String tableRecipeCategories = 'recipe_categories';
  static const String recipeId = 'recipe_id';
  static const String categoryId = 'category_id';

  Future<int> insert(Category category) async {
    return await _db.insert(CategoryService.table, category.toMap());
  }

  Future<int> update(Category category) async {
    return await _db.update(CategoryService.table, category.toMap(), 'id = ?', [
      category.id,
    ]);
  }

  Future<int> delete(String id) async {
    // Verifica se a tag está associada a alguma receita
    final associations = await _db.rawQuery(
      'SELECT 1 FROM ${CategoryService.tableRecipeCategories} WHERE ${CategoryService.categoryId} = ? LIMIT 1',
      [id],
    );
    if (associations.isNotEmpty) {
      throw Exception(
        'Não é possível deletar: tag ainda associada a uma receita.',
      );
    }
    return await _db.delete(CategoryService.table, 'id = ?', [id]);
  }

  Future<Category?> getById(String id) async {
    final category = await _db.getById(CategoryService.table, id);
    if (category != null && category.isNotEmpty) {
      return Category.fromMap(category);
    }
    return null;
  }

  Future<List<Category>> getAll() async {
    List<Map<String, dynamic>> categoriesDB = await _db.getAll(
      CategoryService.table,
    );
    return categoriesDB.map((category) => Category.fromMap(category)).toList();
  }

  Future<int> associateCategoryWithRecipe(int recipeId, int categoryId) async {
    final result = await _db.insert(CategoryService.tableRecipeCategories, {
      CategoryService.recipeId: recipeId,
      CategoryService.categoryId: categoryId,
    });
    if (result == 0) {
      throw Exception('Failed to associate category with recipe');
    }
    return result;
  }

  Future<int> dissociateCategoryFromRecipe(int recipeId, int categoryId) async {
    final result = await _db.delete(
      CategoryService.tableRecipeCategories,
      'recipe_id = ? AND category_id = ?',
      [recipeId, categoryId],
    );
    if (result == 0) {
      throw Exception('Failed to dissociate category from recipe');
    }
    return result;
  }

  Future<List<Category>> getCategoriesByRecipeId(int recipeId) async {
    final categories = await _db.rawQuery(
      'SELECT c.* FROM ${CategoryService.table} c '
      'JOIN ${CategoryService.tableRecipeCategories} rc '
      'ON c.id = rc.category_id WHERE rc.recipe_id = ?',
      [recipeId],
    );
    return categories.map((category) => Category.fromMap(category)).toList();
  }

  Future<List<Recipe>> getRecipesByCategoryId(int categoryId) async {
    final recipes = await _db.rawQuery(
      '''
      SELECT r.* FROM recipes r
      JOIN ${CategoryService.tableRecipeCategories} rc ON r.id = rc.recipe_id
      WHERE rc.category_id = ?
      ''',
      [categoryId],
    );
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  Future<List<Recipe>> getRecipesByCategoryIds(List<int> categoryIds) async {
    final placeholders = List.filled(categoryIds.length, '?').join(',');
    final recipes = await _db.rawQuery('''
    SELECT DISTINCT r.* FROM recipes r
    JOIN ${CategoryService.tableRecipeCategories} rc ON r.id = rc.recipe_id
    WHERE rc.category_id IN ($placeholders)
    ''', categoryIds);
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  Future<List<Category>> searchByName(String name) async {
    final categoriesDB = await _db.searchByName(
      CategoryService.table,
      'name',
      name,
    );
    return categoriesDB.map((item) => Category.fromMap(item)).toList();
  }
}
