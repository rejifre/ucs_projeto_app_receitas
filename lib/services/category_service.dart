import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';

class CategoryService {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'categories';
  static const String tableRecipeCategories = 'recipe_categories';
  static const String recipeId = 'recipe_id';
  static const String categoryId = 'category_id';

  Future<int> insert(CategoryModel category) async {
    return await _db.insert(CategoryService.table, category.toMap());
  }

  // Método para inserção com substituição em caso de conflito (usado na restauração)
  Future<int> insertOrReplace(CategoryModel category) async {
    return await _db.insertOrReplace(CategoryService.table, category.toMap());
  }

  Future<int> update(CategoryModel category) async {
    return await _db.update(CategoryService.table, category.toMap(), 'id = ?', [
      category.id,
    ]);
  }

  Future<int> delete(String id) async {
    // Verifica se a categoria está associada a alguma receita
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

  Future<CategoryModel?> getById(String id) async {
    final category = await _db.getById(CategoryService.table, id);
    if (category != null && category.isNotEmpty) {
      return CategoryModel.fromMap(category);
    }
    return null;
  }

  Future<List<CategoryModel>> getAll() async {
    List<Map<String, dynamic>> categoriesDB = await _db.getAll(
      CategoryService.table,
    );
    return categoriesDB
        .map((category) => CategoryModel.fromMap(category))
        .toList();
  }

  Future<int> associateCategoryWithRecipe(
    String recipeId,
    String categoryId,
  ) async {
    final result = await _db.insert(CategoryService.tableRecipeCategories, {
      CategoryService.recipeId: recipeId,
      CategoryService.categoryId: categoryId,
    });
    if (result == 0) {
      throw Exception('Failed to associate category with recipe');
    }
    return result;
  }

  Future<int> dissociateCategoryFromRecipe(
    String recipeId,
    String categoryId,
  ) async {
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

  /// Remove todas as associações de tags de uma receita
  Future<void> removeCategoriesByRecipeId(String recipeIdValue) async {
    await _db.delete(
      CategoryService.tableRecipeCategories,
      '${CategoryService.recipeId} = ?',
      [recipeIdValue],
    );
  }

  Future<List<CategoryModel>> getCategoriesByRecipeId(String recipeId) async {
    final categories = await _db.rawQuery(
      'SELECT c.* FROM ${CategoryService.table} c '
      'JOIN ${CategoryService.tableRecipeCategories} rc '
      'ON c.id = rc.category_id WHERE rc.recipe_id = ?',
      [recipeId],
    );
    return categories
        .map((category) => CategoryModel.fromMap(category))
        .toList();
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

  /// Atualiza as associações de categorias de uma receita:
  /// Remove todas as associações antigas e insere as novas.
  Future<void> updateRecipeCategories(
    String recipeId,
    List<String> categoryIds,
  ) async {
    // Remove todas as associações antigas
    await _db.delete(
      CategoryService.tableRecipeCategories,
      '${CategoryService.recipeId} = ?',
      [recipeId],
    );
    // Insere as novas associações
    for (final categoryId in categoryIds) {
      await _db.insert(CategoryService.tableRecipeCategories, {
        CategoryService.recipeId: recipeId,
        CategoryService.categoryId: categoryId,
      });
    }
  }

  Future<List<CategoryModel>> searchByName(String name) async {
    final categoriesDB = await _db.searchByName(
      CategoryService.table,
      'name',
      name,
    );
    return categoriesDB.map((item) => CategoryModel.fromMap(item)).toList();
  }

  Future<int> deleteAll() async {
    return await _db.deleteAll(CategoryService.table);
  }

  Future<List<Map<String, dynamic>>> getAllRecipeCategories() async {
    return await _db.getAll(CategoryService.tableRecipeCategories);
  }

  Future<void> insertRecipeCategory(Map<String, dynamic> categoryJson) async {
    await _db.insert(CategoryService.tableRecipeCategories, categoryJson);
  }
}
