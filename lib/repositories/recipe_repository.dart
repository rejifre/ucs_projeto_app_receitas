import '../models/recipe_model.dart';
import '/database/database_helper.dart';

class RecipeRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'recipe';

  Future<void> insert(Recipe recipe) async {
    await _db.insert(table, recipe.toMap());
  }

  Future<void> update(Recipe recipe) async {
    await _db.update(table, recipe.toMap(), 'id = ?', [recipe.id]);
  }

  Future<void> delete(String id) async {
    await _db.delete(table, 'id = ?', [id]);
  }

  Future<Recipe?> getById(String id) async {
    final recipe = await _db.getById(table, id);
    if (recipe != null && recipe.isNotEmpty) {
      return Recipe.fromMap(recipe);
    }
    return null;
  }

  Future<List<Recipe>> getAll() async {
    List<Map<String, dynamic>> recipesDB = await _db.getAll(table);
    List<Recipe> recipes = [];

    for (var item in recipesDB) {
      Recipe recipe = Recipe.fromMap(item);
      recipes.add(recipe);
    }

    return recipes;
  }
}
