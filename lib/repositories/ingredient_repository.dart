import '../models/ingredient_model.dart';

import '/database/database_helper.dart';

class IngredientRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  static const String table = 'ingredient';

  Future<int> insert(Ingredient ingredient) async {
    return await _db.insert(table, ingredient.toMap());
  }

  Future<void> update(String recipeId, List<Ingredient> ingredients) async {
    deleteByRecipeId(recipeId);

    for (var ingredient in ingredients) {
      await _db.insert(table, ingredient.toMap());
    }
  }

  Future<int> delete(String ingredientId) async {
    return await _db.delete(table, 'id = ?', [ingredientId]);
  }

  Future<int> deleteByRecipeId(String recipeId) async {
    return await _db.delete(table, 'recipe_id = ?', [recipeId]);
  }

  Future<Ingredient?> getById(String ingredientId) async {
    final ingredient = await _db.getById(table, ingredientId);
    if (ingredient != null && ingredient.isNotEmpty) {
      return Ingredient.fromMap(ingredient);
    }
    return null;
  }

  Future<List<Ingredient>> getAll(String recipeId) async {
    List<Map<String, dynamic>> ingredientsDB = await _db.getAll(
      table,
      condition: 'recipe_id = ?',
      conditionArgs: [recipeId],
    );

    List<Ingredient> ingredients = [];

    for (var ingr in ingredientsDB) {
      Ingredient ingredient = Ingredient.fromMap(ingr);
      ingredients.add(ingredient);
    }

    return ingredients;
  }
}
